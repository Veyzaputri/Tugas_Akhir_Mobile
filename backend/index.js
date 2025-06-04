import express from "express";
import cors from "cors";
import UserRoute from "./routes/UserRoute.js";
import PasienRoute from "./routes/PasienRoute.js";
import DokterRoute from "./routes/DokterRoute.js";
import PeriksaRoute from "./routes/PeriksaRoute.js";
import ObatRoute from "./routes/ObatRoute.js";
import StrukRoute from "./routes/StrukRoute.js";
import cookieParser from "cookie-parser";
import dotenv from "dotenv";
import sequelize from "./config/Database.js";

dotenv.config();
const app = express();

// Konfigurasi CORS
const corsOptions = {
  origin: 'http://localhost:61354', // sesuaikan dengan asal front-end kamu
  credentials: true,
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"]
};

app.use(cookieParser());
app.use(cors(corsOptions));

// Tambahkan handler untuk preflight request
app.options("*", cors(corsOptions));

// Body parser
app.use(express.json());

// Routes
app.use(UserRoute);
app.use(PasienRoute);
app.use(DokterRoute);
app.use(PeriksaRoute);
app.use(ObatRoute);
app.use(StrukRoute);

// Start server
const start = async () => {
  try {
    await sequelize.authenticate();
    console.log("Database connected");
    await sequelize.sync(); // sinkronisasi model

    const port = process.env.PORT || 5000;

    app.get("/", (req, res) => {
      res.status(200).send("Server berjalan di Cloud Run 🚀");
    });

    app.listen(port, "0.0.0.0", () =>
      console.log(`Server running on port ${port}`)
    );
  } catch (error) {
    console.error("Unable to connect to the database:", error);
  }
};

start();
