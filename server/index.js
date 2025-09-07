const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const mongoSanitize = require("express-mongo-sanitize");
// const xss = require("xss-clean"); // Commented out due to compatibility issues
const bcrypt = require("bcryptjs");   // 🔹 switched to bcryptjs
const jwt = require("jsonwebtoken");
const User = require("./models/User");
require("dotenv").config();

const app = express();

// SECURITY: require a JWT secret in production
if (!process.env.JWT_SECRET) {
  console.error("❌ JWT_SECRET not set. Set JWT_SECRET in your .env and restart the server.");
  process.exit(1);
}
const JWT_SECRET = process.env.JWT_SECRET;

// CORS whitelist - Updated for Flutter web development
const WHITELIST = (process.env.FRONTEND_ORIGINS || "http://localhost:8080,http://localhost:3000,http://localhost:5000").split(",").map(s => s.trim());

const corsOptions = {
  origin: (origin, callback) => {
    // Allow requests with no origin (like mobile apps or Postman)
    if (!origin) {
      console.log("🌐 CORS: Allowing request with no origin");
      return callback(null, true);
    }
    
    // Check if origin is in whitelist
    if (WHITELIST.indexOf(origin) !== -1) {
      console.log(`✅ CORS: Allowing origin: ${origin}`);
      return callback(null, true);
    }
    
    console.log(`❌ CORS: Blocking origin: ${origin}`);
    console.log(`📋 Allowed origins: ${WHITELIST.join(', ')}`);
    return callback(new Error(`CORS policy: Origin ${origin} not allowed`), false);
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  optionsSuccessStatus: 200 // Some legacy browsers choke on 204
};

app.use(cors(corsOptions));

// Preflight handling is already included in the cors() middleware

// Middleware
app.use(helmet());
app.use(express.json({ limit: "10kb" }));
//app.use(mongoSanitize());
// app.use(xss()); // Commented out due to compatibility issues with newer Node.js

// Logger
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.originalUrl}`);
  next();
});

// Rate limiter
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  message: { message: "Too many requests, try again later." },
});
app.use("/login", authLimiter);
app.use("/signup", authLimiter);
app.use("/change-password", authLimiter);

// Health check
app.get("/", (req, res) => res.json({ status: "ok" }));

// Health endpoint for testing CORS
app.get("/health", (req, res) => {
  res.json({ 
    status: "ok", 
    message: "Server is running",
    timestamp: new Date().toISOString(),
    cors: {
      allowedOrigins: WHITELIST,
      currentOrigin: req.headers.origin || 'none'
    }
  });
});

// Test endpoint for Flutter web development
app.get("/test-cors", (req, res) => {
  res.json({
    message: "CORS test successful!",
    origin: req.headers.origin || 'none',
    userAgent: req.headers['user-agent'],
    timestamp: new Date().toISOString()
  });
});

// CORS error handler
app.use((err, req, res, next) => {
  if (err.message && err.message.includes('CORS policy')) {
    console.error('❌ CORS Error:', err.message);
    console.log('🌐 Request Origin:', req.headers.origin);
    console.log('📋 Allowed Origins:', WHITELIST);
    
    return res.status(403).json({
      error: 'CORS Error',
      message: err.message,
      allowedOrigins: WHITELIST,
      currentOrigin: req.headers.origin || 'none',
      help: 'Check if your origin is in the allowed origins list'
    });
  }
  next(err);
});

// Simple auth middleware
function auth(req, res, next) {
  try {
    const authHeader = req.headers.authorization || '';
    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
    if (!token) return res.status(401).json({ message: 'Missing token' });
    const payload = jwt.verify(token, JWT_SECRET);
    req.userId = payload.id;
    return next();
  } catch (e) {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
}

// Validate username/password
function validateCredentials(username, password) {
  if (!username || typeof username !== "string" || username.trim().length < 3) return "Invalid username";
  if (!password || typeof password !== "string" || password.length < 6) return "Password must be at least 6 characters";
  return null;
}

// SIGNUP
app.post("/signup", async (req, res) => {
  try {
    const { username, password, studentName, studentNRC, yearOfStudy, program, school, campus, major, intake, courses } = req.body;

    const err = validateCredentials(username, password);
    if (err) return res.status(400).json({ message: err });

    const existingUser = await User.findOne({ username });
    if (existingUser) return res.status(400).json({ message: "User already exists" });

    const hashed = await bcrypt.hash(password, 10);

    const newUser = new User({
      username,
      password: hashed,
      studentName,
      studentNRC,
      yearOfStudy,
      program,
      school,
      campus,
      major,
      intake,
      courses: Array.isArray(courses) ? courses : [],
    });

    await newUser.save();
    return res.status(201).json({ message: "Signup successful" });
  } catch (err) {
    console.error("❌ Signup error:", err.message || err);
    return res.status(500).json({ message: "Server error" });
  }
});

// LOGIN
app.post("/login", async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) return res.status(400).json({ message: "Username and password required" });

    const user = await User.findOne({ username });
    if (!user) return res.status(401).json({ message: "Invalid credentials" });

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(401).json({ message: "Invalid credentials" });

    const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: "1h" });

    return res.json({
      message: "Login successful",
      token,
      user: {
        username: user.username,
        studentName: user.studentName,
        studentNRC: user.studentNRC,
        yearOfStudy: user.yearOfStudy,
        program: user.program,
        school: user.school,
        campus: user.campus,
        major: user.major,
        intake: user.intake,
        courses: user.courses || [],
      },
    });
  } catch (err) {
    console.error("❌ Login error:", err.message || err);
    return res.status(500).json({ message: "Server error" });
  }
});

// CHANGE PASSWORD
app.post("/change-password", async (req, res) => {
  try {
    const { username, oldPassword, newPassword } = req.body;
    if (!username || !oldPassword || !newPassword) return res.status(400).json({ message: "username, oldPassword and newPassword are required" });

    if (typeof newPassword !== "string" || newPassword.length < 6) return res.status(400).json({ message: "newPassword must be at least 6 characters" });

    const user = await User.findOne({ username });
    if (!user) return res.status(404).json({ message: "User not found" });

    const match = await bcrypt.compare(oldPassword, user.password);
    if (!match) return res.status(400).json({ message: "Old password is incorrect" });

    user.password = await bcrypt.hash(newPassword, 10);
    await user.save();

    return res.json({ message: "Password updated successfully" });
  } catch (error) {
    console.error("❌ Change password error:", error.message || error);
    return res.status(500).json({ message: "Server error" });
  }
});

// Validate token for mobile app
app.get('/validate-token', auth, async (req, res) => {
  return res.json({ message: 'Token valid' });
});

// Accommodation endpoint (placeholder structure)
app.get('/accommodation', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId).lean();
    if (!user) return res.status(404).json({ message: 'User not found' });
    const acc = user.accommodation || null;
    return res.json({
      allocation: acc?.allocation || null,
      roomKey: acc?.roomKey || null,
      fixedProperty: acc?.fixedProperty || [],
      optionalProperty: acc?.optionalProperty || [],
    });
  } catch (e) {
    console.error('❌ Accommodation error:', e.message || e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// Start server
const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI || "mongodb://localhost:27017/unza-sis";

console.log("🔧 Starting server with configuration:");
console.log(`   Port: ${PORT}`);
console.log(`   MongoDB URI: ${MONGO_URI.substring(0, 20)}...`);
console.log(`   CORS Origins: ${WHITELIST.join(', ')}`);

mongoose.connect(MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log("✅ MongoDB connected successfully");
  app.listen(PORT, "0.0.0.0", () => {
    console.log(`✅ Server running on http://localhost:${PORT}`);
    console.log(`🌐 CORS enabled for origins: ${WHITELIST.join(', ')}`);
  });
})
.catch((err) => {
  console.error("❌ MongoDB connection error:", err.message || err);
  console.error("💡 Check your MONGO_URI in .env file");
  process.exit(1);
});
