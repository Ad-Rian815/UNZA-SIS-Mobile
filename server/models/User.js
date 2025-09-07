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
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", UserSchema);
