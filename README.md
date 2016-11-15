With this Coolness Measurement Tool you can measure coolness of audio parts you specify.

To use this tool you need [sox](http://sox.sourceforge.net/) to be installed.
## Usage example
```bash
ruby cmt.rb './samples/Финал Линди Хоп JnJ Open часть 1.mp3' 2:46-3:40 3:40-4:30 4:30-5:17 5:17-6:06 6:06-7:00 7:00-7:30 7:30-7:50 8:04-8:32 8:32-8:59 8:59-9:35
```
will give you
```
    period      coolness
1   4:30-5:17   188
2   3:40-4:30   186
3   5:17-6:06   177
4   8:32-8:59   176
5   7:30-7:50   161
6   6:06-7:00   161
7   7:00-7:30   160
8   8:04-8:32   150
9   2:46-3:40   147
10   8:59-9:35   145
```
