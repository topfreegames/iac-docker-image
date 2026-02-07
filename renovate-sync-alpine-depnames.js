const fs = require("fs");

const dockerfilePath = "Dockerfile";
const repologyApiBase = "https://repology.org/api/v1/project/";

async function fetchRepologyVersion(repo, project) {
  const cacheKey = `${repo}/${project}`;
  if (fetchRepologyVersion.cache.has(cacheKey)) {
    return fetchRepologyVersion.cache.get(cacheKey);
  }

  const url = `${repologyApiBase}${encodeURIComponent(project)}`;
  const res = await fetch(url, {
    headers: { "User-Agent": "renovate-sync-alpine-depnames" },
  });

  if (!res.ok) {
    console.warn(`Repology lookup failed for ${project}: ${res.status}`);
    fetchRepologyVersion.cache.set(cacheKey, null);
    return null;
  }

  const data = await res.json();
  const repoEntries = data.filter((entry) => entry.repo === repo);

  const matched =
    repoEntries.find((entry) => entry.binname === project) ||
    repoEntries.find((entry) => entry.srcname === project) ||
    repoEntries.find((entry) => entry.visiblename === project) ||
    repoEntries[0];

  const version = matched ? matched.origversion || matched.version : null;
  fetchRepologyVersion.cache.set(cacheKey, version || null);
  return version || null;
}
fetchRepologyVersion.cache = new Map();

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
    const newVersion = await fetchRepologyVersion(
      `alpine_${alpineRepo}`,
      project
    );

    const nextValue = newVersion || currentValue;
    if (newVersion && newVersion !== currentValue) {
      console.log(`Updated ${project}: ${currentValue} -> ${newVersion}`);
    }

    const replacement = `# renovate: datasource=repology depName=${newDepName}${commentTail}\nARG ${argName}=${nextValue}`;
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
