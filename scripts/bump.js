#!/usr/bin/env node
//
// Bump the YAMLResume Docker image version across the action files.
// Usage: pnpm bump <version>
//

const fs = require('fs');
const { execSync } = require('child_process');

function normalizeVersion(version) {
  return version.trim();
}

function getPreviousVersion(newVersion) {
  const pattern = /bump yamlresume from \S+ to (\S+)/i;
  try {
    const log = execSync('git log --format=%s', { encoding: 'utf8' });
    for (const line of log.split('\n')) {
      const match = line.match(pattern);
      if (match && match[1] !== newVersion) {
        return match[1];
      }
    }
  } catch {
    // fall through
  }
  throw new Error(
    'Could not determine previous version from git log. ' +
      `Expected a commit like "feat: bump yamlresume from x to y".`
  );
}

function commitChanges(previousVersion, newVersion) {
  const message = `feat: bump yamlresume from ${previousVersion} to ${newVersion}`;
  const files = ['action.yml', 'scripts/build.sh', 'README.md'];
  execSync(`git add -- ${files.map((f) => `"${f}"`).join(' ')}`);
  execSync(`git commit -m ${JSON.stringify(message)}`, {
    stdio: 'inherit',
  });
  console.log(`Committed with message: ${message}`);
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

  const previousVersion = getPreviousVersion(newVersion);

  console.log(`Bumped YAMLResume version to ${newVersion}:`);
  for (const update of updates) {
    console.log(`  ${update.file}: ${update.previous} -> ${newVersion}`);
  }

  commitChanges(previousVersion, newVersion);
}

main();
