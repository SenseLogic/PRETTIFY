# Prettify

Source code prettifier.

## Features

* Prettifies source code files with the following extensions :
  * PHP : php.
  * HTML : html, htm, xml, twig.
  * CSS : css, less, pepss, sass, scss, styl.
  * JavaScript : js, json.
  * C : c, h.
  * C++ : cxx, hxx, cpp, hpp.
  * D : d.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html).

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

### Example

```bash
prettify "*.d"
```

Prettifies all D files.

```bash
prettify --backup BACKUP_FOLDER/ "*.php"
```

Prettifies all PHP files after having stored the original files in "BACKUP_FOLDER/".

```bash
prettify --output OUTPUT_FOLDER/ "*.js"
```

Prettifies all JavaScript files and store the fixed files in "OUTPUT_FOLDER/".

## Version

0.1

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
