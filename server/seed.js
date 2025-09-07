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

    const hashedPassword1 = await bcrypt.hash("2022033809", 10); // hash before saving
    const hashedPassword2 = await bcrypt.hash("2021500001", 10); // second user
    const hashedPassword3 = await bcrypt.hash("2021397963", 10); // existing user

    const accommodatedStudent = {
      username: "2022033809",
      password: hashedPassword1, // 🔹 hashed
      studentName: "Chimwemwe Mhango",
      studentNRC: "789012/34/5",
      yearOfStudy: "2",
      program: "BSc Economics",
      school: "School of Humanities",
      campus: "Main Campus",
      major: "Economics",
      intake: "2023 Intake",
      courses: [
        { code: "ECN 2115", name: "INTERMEDIATE MICROECONOMETRIC THEORY", half_or_full_course: "0" },
        { code: "ECN 2215", name: "INTERMEDIATE MICROECONOMIC THEORY", half_or_full_course: "0" },
        { code: "ECN 2311", name: "MATHEMATICS FOR ECONOMICS I", half_or_full_course: "0" },
        { code: "ECN 2322", name: "MATHEMATICS FOR ECONOMICS II", half_or_full_course: "0" },
        { code: "ECN 2331", name: "STATISTICS: THEORY AND TECHNIQUES FOR ECON", half_or_full_course: "0" },
        { code: "ECN 2342", name: "APPLIED STATISTICS FOR ECONOMICS", half_or_full_course: "0" },
      ],
      accommodation: {
        allocation: {
          hostel: "Africa",
          block: "5",
          level: "4",
          roomType: "Double",
          roomNumber: "27",
          remark: "Welcome to Africa Block 5",
        },
        roomKey: { key: "Room Key", number: "AF5-27" },
        fixedProperty: ["Bed", "Wardrobe", "Desk"],
        optionalProperty: ["Chair"],
      },
    };

    const nonAccommodatedStudent = {
      username: "2020034867",
      password: hashedPassword2,
      studentName: "Beenzu Hadombe Milimo",
      studentNRC: "663094/10/1",
      yearOfStudy: "5",
      program: "BSc Computer Science",
      school: "School of Medicine",
      campus: "Ridgeway Campus",
      major: "Medicine and Surgery",
      intake: "2020 Intake",
      courses: [
        { code: "DEM 5110", name: "MANAGEMENT AND COMMUNITY HEALTH", half_or_full_course: "1" },
        { code: "MED 5610", name: "INTERNAL MEDICINE SUBSPECAILTIES", half_or_full_course: "1" },
        { code: "PSY 5410", name: "PSYCHIATRY AND MENTAL HEALTH", half_or_full_course: "1"},
        { code: "PTM 5510", name: "FORENSIC MEDICINE AND MEDICAL JURISPRUDENCE", half_or_full_course: "1"},
        { code: "SYG 5910", name: "SURGICAL SUBSPECIALTIES", half_or_full_course: "1"},
      ],
      // no accommodation
    };

    const existingStudent = {
      username: "2021397963",
      password: hashedPassword3,
      studentName: "Adrian Phiri",
      studentNRC: "649516/10/1",
      yearOfStudy: "4",
      program: "BSc Computer Science",
      school: "School of Natural Sciences",
      campus: "Main Campus",
      major: "Software Engineering",
      intake: "2022 Intake",
      courses: [
        { code: "CSC4004", name: "PROJECTS", half_or_full_course: "1" },
        { code: "CSC4630", name: "ADVANCED SOFTWARE ENGINEERING", half_or_full_course: "1" },
        { code: "CSC4631", name: "SOFTWARE TESTING AND MAINTENANCE", half_or_full_course: "0" },
        { code: "CSC4035", name: "WEB PROGRAMMING AND TECHNOLOGIES", half_or_full_course: "0" },
        { code: "CSC4642", name: "SOFTWARE AND QUALITY ASSURANCE", half_or_full_course: "0" },
        { code: "CSC4505", name: "GRAPHICS AND VISUAL COMPUTING", half_or_full_course: "0" },
        { code: "CSC4792", name: "DATA MINING AND WAREHOUSING", half_or_full_course: "0" },
        { code: "CSC3009", name: "INDUSTRIAL TRAINING COURSE", half_or_full_course: "0" },
      ],
      // no accommodation in this example
    };

    await User.insertMany([existingStudent, accommodatedStudent, nonAccommodatedStudent]);
    console.log("✅ Seeded users: 2021397963, 2022033809 (accommodated), 2021500001 (no accommodation)");
    mongoose.connection.close();
  } catch (err) {
    console.error("❌ Seeding error:", err);
    mongoose.connection.close();
  }
}

seed();
