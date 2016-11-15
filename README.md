With this **Coolness Measurement Tool** you can measure coolness of audio parts you specify.

To use this tool you need [sox](http://sox.sourceforge.net/) to be installed. To download audio from YouTube you also need [youtube-dl](https://rg3.github.io/youtube-dl/).
## Usage example
Providing youtube url
```bash
ruby cmt.rb 'https://www.youtube.com/watch?v=ICz-edsOaFw' 2:46-3:40 3:40-4:30 4:30-5:17 5:17-6:06 6:06-7:00 7:00-7:30 7:30-7:50 8:04-8:32 8:32-8:59 8:59-9:35
```

will give you
```
    period      coolness
1   3:40-4:30   175
2   4:30-5:17   169
3   5:17-6:06   166
4   8:32-8:59   165
5   7:30-7:50   147
6   6:06-7:00   144
7   8:04-8:32   141
8   7:00-7:30   141
9   8:59-9:35   139
10   2:46-3:40   131
```

Also you can provide local file path
```bash
ruby cmt.rb './samples/Финал Линди Хоп JnJ Open часть 1.mp3' 2:46-3:40 3:40-4:30 4:30-5:17 5:17-6:06 6:06-7:00 7:00-7:30 7:30-7:50 8:04-8:32 8:32-8:59 8:59-9:35
```
