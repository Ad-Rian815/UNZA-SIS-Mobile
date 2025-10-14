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
    const hashedPassword2 = await bcrypt.hash("2020034867", 10); // second user
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
      intake: "2022 Intake",
      sex: "MALE",
      nationality: "ZAMBIAN",
      sponsor: "SELF",
      phone: "076 253 4183",
      residentialAddress: "UNZA Main Campus",
      postalAddress: "P.O. Box 32379",
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
      finance: {
        fees: [
          { description: 'Tuition Fee', amount: 12000, term: 'GER', year: 2024 },
          { description: 'Other Fees', amount: 2500, term: 'GER', year: 2024 },
        ],
        payments: [
          { date: new Date('2024-10-01'), amount: 6000, method: 'Mobile Money', reference: 'TXN-2024-001', description: 'Part payment', term: 'GER', year: 2024 },
        ],
      },
      results: {
        academicYears: [
          {
            year: "GER 20241",
            programme: "BACHELOR OF ECONOMICS - 2ND YEAR",
            status: null,
            courses: [
              { code: "ECN 2115", name: "INTERMEDIATE MICROECONOMETRIC THEORY", grade: "NOT PUBLISHED", credits: 0, comment: "" },
              { code: "ECN 2215", name: "INTERMEDIATE MICROECONOMIC THEORY", grade: "***", credits: 0, comment: "" },
              { code: "ECN 2311", name: "MATHEMATICS FOR ECONOMICS I", grade: "***", credits: 0, comment: "" },
              { code: "ECN 2322", name: "MATHEMATICS FOR ECONOMICS II", grade: "***", credits: 0, comment: "" },
              { code: "ECN 2331", name: "STATISTICS: THEORY AND TECHNIQUES FOR ECON", grade: "***", credits: 0, comment: "" },
              { code: "ECN 2342", name: "APPLIED STATISTICS FOR ECONOMICS", grade: "***", credits: 0, comment: "" },
            ],
          },
          {
            year: "GER 20231",
            programme: "BACHELOR OF ECONOMICS - 1ST YEAR",
            status: "CLEAR PASS",
            courses: [
              { code: "ECN 1101", name: "INTRODUCTION TO ECONOMICS", grade: "B+", credits: 0, comment: "" },
              { code: "ECN 1202", name: "MICROECONOMICS", grade: "B", credits: 0, comment: "" },
              { code: "ECN 1303", name: "MACROECONOMICS", grade: "B+", credits: 0, comment: "" },
              { code: "MAT 1100", name: "FOUNDATION MATHEMATICS", grade: "C+", credits: 0, comment: "" },
              { code: "STA 1201", name: "INTRODUCTION TO STATISTICS", grade: "B", credits: 0, comment: "" },
            ],
          },
        ],
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
      sex: "MALE",
      nationality: "ZAMBIAN",
      sponsor: "GRZ FULLY SPONSORED",
      phone: "097 049 1580",
      residentialAddress: "Kudu Rd 34, Lusaka",
      postalAddress: "P.O. Box 30000",
      courses: [
        { code: "DEM 5110", name: "MANAGEMENT AND COMMUNITY HEALTH", half_or_full_course: "1" },
        { code: "MED 5610", name: "INTERNAL MEDICINE SUBSPECAILTIES", half_or_full_course: "1" },
        { code: "PSY 5410", name: "PSYCHIATRY AND MENTAL HEALTH", half_or_full_course: "1"},
        { code: "PTM 5510", name: "FORENSIC MEDICINE AND MEDICAL JURISPRUDENCE", half_or_full_course: "1"},
        { code: "SYG 5910", name: "SURGICAL SUBSPECIALTIES", half_or_full_course: "1"},
      ],
      // GRZ covers 100% → treat as no fees due and no payments required
      finance: {
        fees: [],
        payments: [],
      },
      results: {
        academicYears: [
          {
            year: "GER 20241",
            programme: "BACHELOR OF MEDICINE AND SURGERY - 5TH YEAR",
            status: null,
            courses: [
              { code: "DEM 5110", name: "MANAGEMENT AND COMMUNITY HEALTH", grade: "NOT PUBLISHED", credits: 1, comment: "" },
              { code: "MED 5610", name: "INTERNAL MEDICINE SUBSPECAILTIES", grade: "***", credits: 1, comment: "" },
              { code: "PSY 5410", name: "PSYCHIATRY AND MENTAL HEALTH", grade: "***", credits: 1, comment: "" },
              { code: "PTM 5510", name: "FORENSIC MEDICINE AND MEDICAL JURISPRUDENCE", grade: "***", credits: 1, comment: "" },
              { code: "SYG 5910", name: "SURGICAL SUBSPECIALTIES", grade: "***", credits: 1, comment: "" },
            ],
          },
          {
            year: "GER 20231",
            programme: "BACHELOR OF MEDICINE AND SURGERY - 4TH YEAR",
            status: "PROCEED",
            courses: [
              { code: "MED 4501", name: "CLINICAL MEDICINE", grade: "B+", credits: 1, comment: "" },
              { code: "SUR 4601", name: "GENERAL SURGERY", grade: "B", credits: 1, comment: "" },
              { code: "PED 4701", name: "PEDIATRICS", grade: "A-", credits: 1, comment: "" },
              { code: "OBG 4801", name: "OBSTETRICS AND GYNECOLOGY", grade: "B+", credits: 1, comment: "" },
            ],
          },
        ],
      },
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
      intake: "2021 Intake",
      sex: "MALE",
      nationality: "ZAMBIAN",
      sponsor: "GRZ FULLY SPONSORED",
      phone: "077 074 9109",
      residentialAddress: "Ibex Hill, Kabulonga Rd 21, Lusaka",
      postalAddress: "P.O. Box 32379",
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
      // GRZ covers 100% → no fees due, no payments required
      finance: {
        fees: [],
        payments: [],
      },
      results: {
        academicYears: [
          {
            year: "GER 20241",
            programme: "BACHELOR OF COMPUTER SCIENCE - SOFTWARE ENGINEERING 4TH YEAR",
            status: null,
            courses: [
              { code: "CSC 4642", name: "SOFTWARE AND QUALITY ASSURANCE", grade: "NOT PUBLISHED", credits: 0, comment: "" },
              { code: "CSC 4035", name: "WEB PROGRAMMING AND TECHNOLOGIES", grade: "***", credits: 0, comment: "" },
              { code: "CSC 4631", name: "SOFTWARE TESTING AND MAINTENANCE", grade: "***", credits: 0, comment: "" },
              { code: "CSC 4630", name: "ADVANCED SOFTWARE ENGEERING", grade: "***", credits: 0, comment: "" },
              { code: "CSC 4505", name: "GRAPHICS AND VISUAL COMPUTING", grade: "***", credits: 0, comment: "" },
              { code: "CSC 4004", name: "PROJECTS", grade: "***", credits: 0, comment: "" },
              { code: "CSC 3009", name: "INDUSTRIAL TRAINING COURSE", grade: "***", credits: 0, comment: "" },
            ],
          },
          {
            year: "GER 20231",
            programme: "BACHELOR OF COMPUTER SCIENCE - SOFTWARE ENGINEERING 3RD YEAR",
            status: "PROCEED",
            courses: [
              { code: "CSC 3600", name: "SOFTWARE ENGINEERING", grade: "C+", credits: 0, comment: "" },
              { code: "CSC 3301", name: "PROGRAMMING LANGUAGES DESIGN & IMPLEMENTAT", grade: "C", credits: 0, comment: "" },
              { code: "CSC 3801", name: "DATA COMMUNICATION & NETWORKS", grade: "B", credits: 0, comment: "" },
              { code: "CSC 3612", name: "IT PROJECT MANAGEMENT", grade: "C+", credits: 0, comment: "" },
              { code: "CSC 3712", name: "ADVANCED DATABASES", grade: "C+", credits: 0, comment: "" },
              { code: "CSC 3011", name: "ALGORITHM AND COMPLEXITY", grade: "C+", credits: 0, comment: "" },
              { code: "CSC 3402", name: "FUNDAMENTALS OF ARTIFICIAL INTELLIGENCE", grade: "C+", credits: 0, comment: "" },
              { code: "CSC 3009", name: "INDUSTRIAL TRAINING COURSE", grade: "IN", credits: 0, comment: "" },
            ],
          },
          {
            year: "GER 20221",
            programme: "BACHELOR OF COMPUTER SCIENCE - SOFTWARE ENGINEERING 2ND YEAR",
            status: "CLEAR PASS",
            courses: [
              { code: "CSC 2901", name: "DISCRETE STRUCTURES", grade: "B", credits: 0, comment: "" },
              { code: "CSC 2101", name: "COMPUTER SYSTEMS", grade: "B", credits: 0, comment: "" },
              { code: "CSC 2111", name: "COMPUTER ARCHITECTURE", grade: "B", credits: 0, comment: "" },
              { code: "CSC 2702", name: "DATABASE & INFORMATION MANAGEMENT SYSTEM", grade: "B", credits: 0, comment: "" },
              { code: "CSC 2202", name: "OPERATING SYSTEMS", grade: "B", credits: 0, comment: "" },
              { code: "CSC 2000", name: "COMPUTER PROGRAMMING", grade: "C+", credits: 0, comment: "" },
              { code: "CSC 2912", name: "NUMERICAL ANALYSIS", grade: "C+", credits: 0, comment: "" },
            ],
          },
          {
            year: "GER 20211",
            programme: "BACHELOR OF COMPUTER SCIENCE - SOFTWARE ENGINEERING 1ST YEAR",
            status: "CLEAR PASS",
            courses: [
              { code: "PHY 1010", name: "INTRODUCTORY PHYSICS", grade: "C+", credits: 0, comment: "" },
              { code: "CHE 1000", name: "INTRODUCTORY CHEMISTRY", grade: "C+", credits: 0, comment: "" },
              { code: "BIO 1401", name: "CELLS AND BIOMOLECULES", grade: "B", credits: 0, comment: "" },
              { code: "BIO 1412", name: "MOLECULAR BIOLOGY AND GENETICS", grade: "B+", credits: 0, comment: "" },
              { code: "MAT 1100", name: "FOUNDATION MATHEMATICS", grade: "C", credits: 0, comment: "" },
            ],
          },
        ],
      },
    };

    await User.insertMany([existingStudent, accommodatedStudent, nonAccommodatedStudent]);
    console.log("✅ Seeded users: 2021397963 (GRZ), 2022033809 (self), 2020034867 (GRZ)");
    mongoose.connection.close();
  } catch (err) {
    console.error("❌ Seeding error:", err);
    mongoose.connection.close();
  }
}

seed();

