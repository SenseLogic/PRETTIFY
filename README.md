![](https://github.com/senselogic/PRETTIFY/blob/master/LOGO/prettify.png)

# Prettify

Source code prettifier.

## Features

* Make source code files with the following extensions adhere to [Coda](https://github.com/senselogic/CODA) spacing rules :
  * C : .c .h
  * C++ : .cxx .hxx .cpp .hpp
  * C# : .cs
  * CSS : .css .less .pepss .sass .scss .styl
  * JavaScript : .js .jsx .ts .tsx .json
  * HTML : .htm .html .xml .twig
  * D : .d
  * Dart : .dart
  * PHP : .php
  * Rust : .rs

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 prettify.d
```

## Command line

```bash
prettify [options] file_path_filter
```

### Options

```bash
--backup BACKUP_FOLDER/ : store the original files in this folder
--output OUTPUT_FOLDER/ : store the fixed files in this folder
```

### Examples

```bash
prettify ".//*.d"
```

Prettifies all D files in the current folder and its subfolders.

```bash
prettify --backup BACKUP_FOLDER/ "*.php"
```

Prettifies all PHP files after having stored the original files in "BACKUP_FOLDER/".

```bash
prettify --output OUTPUT_FOLDER/ "*.js"
```

Prettifies all JavaScript files and store the fixed files in "OUTPUT_FOLDER/".

## Limitations

- Tabs are systematically converted to four spaces.
- The lexer does not support verbatim strings, raw string literals, interpolated strings and regular expressions.

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
