# timelapseit

Simple BASH script to create a video output from images tested in Ubuntu 16.04.


## Requirements

* ffmpg: `sudo apt install ffmpeg`


## Usage example

Assuming we have all the `.JPG` images we want to convert into a timelapse in `my_dir/with/images/` at 12 fps:

```bash
	./timelapseit.sh my_dir/with/images JPG 12
```

What will produce a video named `output.avi` in `my_dir/with/images/renamed/resized/`

