#!/usr/bin/env node
//
// Bump the YAMLResume Docker image version across the action files.
// Usage: pnpm bump <version>
//

const fs = require('fs');

function normalizeVersion(version) {
  return version.trim();
}

function readFile(filePath) {
  return fs.readFileSync(filePath, 'utf8');
}

function writeFile(filePath, content) {
  fs.writeFileSync(filePath, content, 'utf8');
}

function updateActionYml(version) {
  const path = 'action.yml';
  const content = readFile(path);
  const match = content.match(/(version:\s*\n\s+description:\s*YAMLResume Docker image version\s*\n\s+required:\s*false\s*\n\s+default:\s*)([^\n]+)/);

  if (!match) {
    throw new Error(`Could not find version input in ${path}`);
  }

  const newContent = content.replace(match[0], `${match[1]}${version}`);
  writeFile(path, newContent);
  return match[2];
}

function updateBuildSh(version) {
  const path = 'scripts/build.sh';
  const content = readFile(path);
  const match = content.match(/(VERSION="\$\{INPUT_VERSION:-)([^}]+)(\}")/);

  if (!match) {
    throw new Error(`Could not find VERSION default in ${path}`);
  }

  const newContent = content.replace(match[0], `${match[1]}${version}${match[3]}`);
  writeFile(path, newContent);
  return match[2];
}

function updateReadme(version) {
  const path = 'README.md';
  const content = readFile(path);
  const match = content.match(/(\|\s*`version`\s*\|\s*YAMLResume Docker image version\s*\|\s*No\s*\|\s*`)([^`]+)(`\s*\|)/);

  if (!match) {
    throw new Error(`Could not find version input row in ${path}`);
  }

  const newContent = content.replace(match[0], `${match[1]}${version}${match[3]}`);
  writeFile(path, newContent);
  return match[2];
}

function main() {
  const newVersion = normalizeVersion(process.argv[2] || '');

  if (!newVersion) {
    console.error('Usage: pnpm bump <version>');
    process.exit(1);
  }

  const updates = [
    { file: 'action.yml', previous: updateActionYml(newVersion) },
    { file: 'scripts/build.sh', previous: updateBuildSh(newVersion) },
    { file: 'README.md', previous: updateReadme(newVersion) },
  ];

  console.log(`Bumped YAMLResume version to ${newVersion}:`);
  for (const update of updates) {
    console.log(`  ${update.file}: ${update.previous} -> ${newVersion}`);
  }
}

main();
