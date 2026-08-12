import {existsSync, readdirSync, readFileSync, writeFileSync} from 'node:fs';
import {basename, join, relative} from 'node:path';

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

function buildUniversal() {
	const root = 'src/games/universal - base';
	const output = 'src/games/universal.lua';
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
}

function indent(text, prefix) {
	return text.split('\n').map((line) => prefix + line).join('\n');
}

function buildGui(name) {
	const root = join('src/guis', name);
	const sourcePath = join(root, 'gui.lua');
	const componentRoot = join(root, 'components');
	const output = join('src/guis', `${name}.lua`);
	let source = readFileSync(sourcePath, 'utf8');

	if (existsSync(componentRoot)) {
		const componentFiles = readdirSync(componentRoot, {withFileTypes: true})
			.filter((entry) => entry.isFile() && entry.name.endsWith('.lua'))
			.map((entry) => join(componentRoot, entry.name))
			.sort((a, b) => a.localeCompare(b));
		const marker = '--Components';
		if (source.split(marker).length !== 2) {
			throw new Error(`${sourcePath} must contain exactly one ${marker} marker.`);
		}

		const components = componentFiles.map((file) => {
			const componentName = basename(file, '.lua');
			const body = indent(readFileSync(file, 'utf8').trimEnd(), '\t\t');
			return `\t${componentName} = function(optionsettings, children, api)\n${body}\n\tend,`;
		}).join('\n');
		source = source.replace(marker, `${marker}\n${components}`);
		console.log(`Built ${output} with ${componentFiles.length} components.`);
	} else {
		console.log(`Built ${output} without external components.`);
	}

	writeFileSync(output, source.endsWith('\n') ? source : `${source}\n`);
}

buildUniversal();
for (const name of ['new', 'old', 'rise', 'liquidbounce', 'wurst']) {
	buildGui(name);
}
