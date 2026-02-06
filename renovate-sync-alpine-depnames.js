const fs = require("fs");

const dockerfilePath = "Dockerfile";

const contents = fs.readFileSync(dockerfilePath, "utf8");
const fromMatch = contents.match(/^FROM\s+alpine:([^\s]+)\s*$/m);

if (!fromMatch) {
  console.error("Could not find FROM alpine:<version> in Dockerfile.");
  process.exit(1);
}

const rawVersion = fromMatch[1];
const cleanedVersion = rawVersion.split("-")[0];
const parts = cleanedVersion.split(".");

if (parts.length < 2) {
  console.error(`Alpine version "${rawVersion}" is not major.minor.`);
  process.exit(1);
}

const alpineRepo = `${parts[0]}_${parts[1]}`;
const updated = contents.replace(
  /depName=alpine_\d+_\d+/g,
  `depName=alpine_${alpineRepo}`
);

if (updated !== contents) {
  fs.writeFileSync(dockerfilePath, updated);
  console.log(`Updated depName=alpine_${alpineRepo} references.`);
} else {
  console.log("No depName=alpine_* references to update.");
}
