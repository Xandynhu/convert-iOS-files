# Process IPhone imported files.

Just a script to convert files imported from an iPhone XR to a format that can be used in a Windows environment.

The script assumes that it is beeing in a Linux environment with access to the Windows file system (e.g. via WSL installation).

# Important Notes

1. The conversion is done in place, so the original files will be overwritten by the converted ones.

# Conversions

1. All extensions are converted to lowercase.
2. **JPG**, **HEIC**, and **HEIF** files are converted to **jpeg**.
3. **MOV** files are converted to **mp4**.

# Usage

1. Copy the files from the iPhone to a directory on the Windows file system.
2. Run the script in the directory where the files are located. It work recursively, so it will process all files in the directory and its subdirectories.
3. **Recommended**: Run the script piping the output to a log file, so you can check for errors later.
    ```bash
    ./convert.sh > conversion_output.log
    ```

# Requirements

1. heif-convert *(sudo apt install libheif-examples)*
2. ffmpeg *(sudo apt install ffmpeg)*
