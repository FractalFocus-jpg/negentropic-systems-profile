import { readdir } from "node:fs/promises";
import { join } from "node:path";

const chunkDir = join(import.meta.dir, "chunks");
const names = (await readdir(chunkDir)).filter((x) => x.endsWith(".txt")).sort();
const pieces = await Promise.all(names.map((name) => Bun.file(join(chunkDir, name)).text()));
const source = pieces.join("");
const target = "/tmp/r144-s311-evaluator.mjs";
await Bun.write(target, source);
await import(target);
