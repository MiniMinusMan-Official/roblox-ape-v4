import {readdirSync, readFileSync, writeFileSync} from 'node:fs';
import {join, relative} from 'node:path';

const root = 'src/games/universal - base';
const output = 'src/games/universal.lua';

function findLuaFiles(directory) {
	const files = [];
	for (const entry of readdirSync(directory, {withFileTypes: true})) {
		const path = join(directory, entry.name);
		if (entry.isDirectory()) {
			files.push(...findLuaFiles(path));
		} else if (entry.isFile() && entry.name.endsWith('.lua')) {
			files.push(path);
		}
	}
	return files;
}

const files = findLuaFiles(root).sort((a, b) => {
	if (a === join(root, 'base.lua')) return -1;
	if (b === join(root, 'base.lua')) return 1;
	return a.localeCompare(b);
});

const bundle = files.map((file) => {
	const name = relative(root, file).replaceAll('\\', '/');
	return `-- BEGIN ${name}\n${readFileSync(file, 'utf8').trimEnd()}\n-- END ${name}`;
}).join('\n\n');

writeFileSync(output, `${bundle}\n`);
console.log(`Built ${output} from ${files.length} source files.`);
