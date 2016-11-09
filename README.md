# crawl-wiki-modules
Lua modules and related tools for generating content for the Crawl Wiki (http://crawl.chaosforge.org).

## Modules
* `spell.lua` -> http://crawl.chaosforge.org/Module:Spell
* `spellbook.lua` -> http://crawl.chaosforge.org/Module:Spellbook
* `string.lua` -> http://crawl.chaosforge.org/Module:String

## Data Tables
[json-data branch](https://github.com/plampila/crawl/tree/json-data) of Crawl includes a tool that outputs a JSON data table.

Lua data tables can be extracted from that data with `tools/json_to_table.lua`.
[Serpent](https://github.com/pkulchenko/serpent) Lua serializer is required.

* `table_of_spells.lua` -> http://crawl.chaosforge.org/Module:Table_of_spells
* `table_of_spellbooks.lua` -> http://crawl.chaosforge.org/Module:Table_of_spellbooks
