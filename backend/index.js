import express from "express";
import cookieParser from "cookie-parser";
import dotenv from "dotenv";
import sequelize from "./config/Database.js";
import UserRoute from "./routes/UserRoute.js";
import PasienRoute from "./routes/PasienRoute.js";
import DokterRoute from "./routes/DokterRoute.js";
import PeriksaRoute from "./routes/PeriksaRoute.js";
import ObatRoute from "./routes/ObatRoute.js";
import StrukRoute from "./routes/StrukRoute.js";

dotenv.config();
const app = express();

app.use(cookieParser());
app.use(express.json());

// Routes
app.use(UserRoute);
app.use(PasienRoute);
app.use(DokterRoute);
app.use(PeriksaRoute);
app.use(ObatRoute);
app.use(StrukRoute);

const start = async () => {
  try {
    await sequelize.authenticate();
    console.log("Database connected");
    await sequelize.sync();

    const port = process.env.PORT || 5000;

    app.get("/", (req, res) => {
      res.status(200).send("Server berjalan 🚀");
    });

    app.listen(port, "0.0.0.0", () =>
      console.log(`Server running on port ${port}`)
    );
  } catch (error) {
    console.error("Unable to connect to the database:", error);
  }
};

start();
