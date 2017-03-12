With **Coolness Measurement Tool** you can measure coolness of video parts by emotions on faces and noise level.

## Installation

Install [sox](http://sox.sourceforge.net/), [ffmpeg](https://ffmpeg.org/) and [youtube-dl](https://rg3.github.io/youtube-dl/).
Generally it's easy.

Mac
```bash
brew install sox ffmpeg youtube-dl
```

Ubuntu
```bash
sudo apt-get install sox libsox-fmt-mp3 ffmpeg youtube-dl
```

Install missing gems
```bash
bundle install
```

Copy file for keys
```bash
cp secrets.yml.public secrets.yml
```

Register here https://www.microsoft.com/cognitive-services/en-us/emotion-api, get Emotion-Preview api key and paste it in `secrets.yml` file.

## Usage
Providing youtube url
```bash
ruby main.rb 'https://www.youtube.com/watch?v=ICz-edsOaFw' 2:46-3:40 3:40-4:30 4:30-5:17 5:17-6:06 6:06-7:00 7:00-7:30 7:30-7:50 8:04-8:32 8:32-8:59 8:59-9:35
```

will give you
```
#   period       coolness   happiness  noise
1   3:40-4:30    943        887        1000
2   5:17-6:06    893        1000       787
3   4:30-5:17    844        821        867
4   6:06-7:00    519        751        287
5   7:30-7:50    449        536        362
6   8:32-8:59    388        0          777
7   2:46-3:40    228        456        0
8   8:04-8:32    207        180        235
9   7:00-7:30    164        102        227
10  8:59-9:35    123        58         189
```

Also you can provide local file path
```bash
ruby main.rb './video/Финал Линди Хоп JnJ Open часть 1-ICz-edsOaFw.mp4' 2:46-3:40 3:40-4:30 4:30-5:17 5:17-6:06 6:06-7:00 7:00-7:30 7:30-7:50 8:04-8:32 8:32-8:59 8:59-9:35
```
