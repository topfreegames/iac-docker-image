const fs = require("fs");

const dockerfilePath = "Dockerfile";

async function main() {
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
  const depRegex =
    /# renovate: datasource=repology depName=alpine_\d+_\d+\/([^\s]+)([^\n]*)\nARG ([A-Z0-9_]+)=([^\n]+)/g;

  let updated = "";
  let lastIndex = 0;
  let changed = false;
  let match;

  while ((match = depRegex.exec(contents)) !== null) {
    const [fullMatch, project, commentTail, argName, currentValue] = match;
    updated += contents.slice(lastIndex, match.index);

    const newDepName = `alpine_${alpineRepo}/${project}`;
    const replacement = `# renovate: datasource=repology depName=${newDepName}${commentTail}\nARG ${argName}=${currentValue}`;
    if (replacement !== fullMatch) {
      changed = true;
    }
    updated += replacement;
    lastIndex = match.index + fullMatch.length;
  }

  updated += contents.slice(lastIndex);

  if (changed) {
    fs.writeFileSync(dockerfilePath, updated);
    console.log(`Updated repology depName references to alpine_${alpineRepo}.`);
  } else {
    console.log("No repology depName references to update.");
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
