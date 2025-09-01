const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");   // 🔹 switched to bcryptjs
const User = require("./models/User");
require("dotenv").config();

async function seed() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("✅ MongoDB connected");

    // Clear existing users (optional)
    await User.deleteMany();

    const hashedPassword = await bcrypt.hash("2021397963", 10); // hash before saving

    const testStudent = new User({
      username: "2021397963",
      password: hashedPassword, // 🔹 hashed
      studentName: "John Banda",
      studentNRC: "123456/12/1",
      yearOfStudy: "3",
      program: "BSc Computer Science",
      school: "School of Natural Sciences",
      campus: "Main Campus",
      major: "Software Engineering",
      intake: "2021 Intake",
      courses: [
        { code: "CSC4630", name: "Advanced Software Engineering", half_or_full_course: "1" },
        { code: "CSC3620", name: "Database Systems", half_or_full_course: "0" },
        { code: "CSC2510", name: "Operating Systems", half_or_full_course: "1" },
      ],
    });

    await testStudent.save();
    console.log("✅ Test student inserted!");
    mongoose.connection.close();
  } catch (err) {
    console.error("❌ Seeding error:", err);
    mongoose.connection.close();
  }
}

seed();
