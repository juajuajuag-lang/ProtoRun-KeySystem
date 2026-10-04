const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const fs = require("fs");
const path = require("path");

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const keysPath = path.join(__dirname, "..", "config", "keys.json");

function loadKeys() {
    try {
        const data = fs.readFileSync(keysPath, "utf8");
        return JSON.parse(data);
    } catch (error) {
        console.error("Error leyendo keys.json:", error.message);
        return { keys: [] };
    }
}

app.get("/", (req, res) => {
    res.json({
        name: "ProtoRun KeySystem",
        status: "online"
    });
});

app.post("/verify", (req, res) => {
    const { key } = req.body;

    if (typeof key !== "string" || key.trim() === "") {
        return res.status(400).json({
            valid: false,
            reason: "INVALID_KEY"
        });
    }

    const data = loadKeys();

    const foundKey = data.keys.find(
        item => item.key === key.trim()
    );

    if (!foundKey) {
        return res.json({
            valid: false,
            reason: "INVALID_KEY"
        });
    }

    if (foundKey.active !== true) {
        return res.json({
            valid: false,
            reason: "KEY_DISABLED"
        });
    }

    res.json({
        valid: true,
        reason: "VALID"
    });
});

app.listen(PORT, () => {
    console.log(`ProtoRun backend iniciado en el puerto ${PORT}`);
});
