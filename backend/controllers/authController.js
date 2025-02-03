const User = require("../models/User");

const admin = require("firebase-admin");
const crypto = require("crypto");


// exports.login = async (req, res) => {
//   const { email, password } = req.body;
//   try {
//     const user = await User.findOne({ email, password });
//     if (user) {
//       res.status(200).json(user);
//     } else {
//       res.status(401).json({ message: "Invalid credentials" });
//     }
//   } catch (err) {
//     res.status(500).json({ message: "Server error" });
//   }
// };


// module.exports.login = async (req, res) => {
//   const { email, password } = req.body;
//   try {
//     const user = await User.findOne({ email, password });
//     if (user) {
//       const token = jwt.sign({ email: user.email }, process.env.JWT_SECRET);
//       res.status(200).json({ token });
//     } else {
//       res.status(401).json({ message: "Invalid credentials" });
//     }
//   } catch (err) {
//     res.status(500).json({ message: "Server error" });
//   }
// }

module.exports = {
  createUser:async(req,res)=>{
    const user = req.body;
    try{
      await admin.auth().getUserByEmail(user.email);

      return res.status(400).json({message:"User already exists"});
    }catch(error){
      if(error.code === "auth/user-not-found"){
        try{
          const userResponse = await admin.auth().createUser({
            email:user.email,
            password:user.password,
            emailVerified:false,
            disabled:false,
          }); 
          console.log(userResponse.uid);

          const newUser = await new User({
            uid:userResponse.uid,
            email:user.email,
            password:crypto.AES.encrypt(user.password,process.env.SECRET).toString(),
            username:user.username,
            location:user.location,
            phone:user.phone,
          }).newUser.save();  
          res.status(201).json({stats:true});
      }catch(error){
        return res.status(500).json({error:"An error occured while creating user"});
      } 
    }
  }
}
}



