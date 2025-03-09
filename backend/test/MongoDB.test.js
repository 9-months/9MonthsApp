/*
 File: MongoDB.test.js
 Purpose: Testing MongoDB Connections.
 Created Date: 2025-02-03 CCS-40 Melissa Joanne
 Author: Melissa Joanne

*/

require("dotenv").config(); // Load environment variables
const { MongoClient } = require("mongodb");

const uri = process.env.MONGODB_URI; // Get URI from .env

describe("MongoDB Connection Test", () => {
    let client;

    beforeAll(async () => {
        if (!uri) {
            throw new Error("MONGODB_URI is not defined in the .env file.");
        }

        client = new MongoClient(uri);
        await client.connect();
    });

    it("should connect to MongoDB and list databases", async () => {
        const admin = client.db().admin();
        const result = await admin.listDatabases();

        expect(result.databases).toBeInstanceOf(Array);
        expect(result.databases.length).toBeGreaterThan(0);
    });

    afterAll(async () => {
        await client.close();
    });
});
