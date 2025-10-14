// models/User.js
const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema(
  {
    username: { type: String, required: true, unique: true }, // computerNo
    password: { type: String, required: true },

    studentName: { type: String },
    studentNRC: { type: String },
    yearOfStudy: { type: String },
    program: { type: String },
    school: { type: String },
    campus: { type: String },
    major: { type: String },
    intake: { type: String },
    sex: { type: String },
    nationality: { type: String },
    sponsor: { type: String },
    // Contact fields (editable in bio data page)
    phone: { type: String },
    residentialAddress: { type: String },
    postalAddress: { type: String },
    courses: [
      {
        code: String,
        name: String,
        half_or_full_course: String, // "1" = Full, "0" = Half
      },
    ],
    // Optional accommodation info
    accommodation: {
      allocation: {
        hostel: String,
        block: String,
        level: String,
        roomType: String,
        roomNumber: String,
        remark: String,
      },
      roomKey: {
        key: String,
        number: String,
      },
      fixedProperty: [String],
      optionalProperty: [String],
    },
    // Optional finance info
    finance: {
      fees: [
        {
          description: String,
          amount: { type: Number, default: 0 },
          term: String,
          year: Number,
        },
      ],
      payments: [
        {
          date: Date,
          amount: { type: Number, default: 0 },
          method: String,
          reference: String,
          description: String,
          term: String,
          year: Number,
        },
      ],
    },
    // Optional results info
    results: {
      academicYears: [
        {
          year: String, // e.g., "GER 20241", "GER 20231"
          programme: String, // e.g., "BACHELOR OF COMPUTER SCIENCE - SOFTWARE ENGINEERING 4TH YEAR"
          status: String, // e.g., "PROCEED", "CLEAR PASS", null
          courses: [
            {
              code: String, // e.g., "CSC 4642"
              name: String, // e.g., "SOFTWARE AND QUALITY ASSURANCE"
              grade: String, // e.g., "A", "B+", "C", "IN", "***", "NOT PUBLISHED"
              credits: { type: Number, default: 0 },
              comment: String,
            },
          ],
        },
      ],
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", UserSchema);
