# Audio Channel Extractor & Concatenator

A powerful Bash script designed to easily extract and concatenate separate audio WAV channels from multitrack container files (32 channels). Perfect for audio engineers and post-production workflows dealing with multi-channel audio recordings split across multiple files.

## Features

- 🎚️ **Multi-channel Extraction**: Extract individual channels from 32-channel WAV files
- 🔄 **File Concatenation**: Automatically join multiple audio chunks into continuous channels
- 🖱️ **Drag & Drop Interface**: Simple folder selection with drag & drop support
- ⚙️ **Customizable Settings**: Adjust channel count and output naming
- 📊 **Real-time Progress**: Detailed processing summary and status updates
- 🐛 **Debug Logging**: Comprehensive log file for troubleshooting

## Prerequisites

- **FFmpeg** must be installed and accessible in your system PATH
- Bash shell environment (Linux, macOS, or Windows with WSL/Cygwin)
- Audio files in WAV format with multiple channels

## Installation

1. Download the script file ['chunk_extract.sh'](https://github.com/MatiqBushwick/AUDIO_MULTITRACK_EXTRACTOR/raw/refs/heads/main/chunk_extract.sh)
2. Make it executable:
   ```bash
   chmod +x chunk_extract.sh
   ```
3. Ensure FFmpeg is installed:
   ```bash
   # Ubuntu/Debian
   sudo apt install ffmpeg
   
   # macOS with Homebrew
   brew install ffmpeg
   
   # Windows (via chocolatey)
   choco install ffmpeg
   ```

## Usage

### Basic Usage
```bash
./chunk_extract.sh
```

### Step-by-Step Process

1. **Run the script** - Execute the script in your terminal
2. **Folder Selection** - Either:
   - Drag and drop your audio folder into the terminal
   - Press Enter to use the current directory
3. **Configuration** - Set:
   - Number of channels (default: 32)
   - Output file prefix (default: "CH")
4. **Processing** - Script automatically:
   - Detects all WAV files in the folder
   - Sorts them numerically
   - Extracts and concatenates each channel
   - Creates individual output files for each channel

### Input File Requirements

- Files must have `.WAV` extension (uppercase)
- Files should be named in a way that sorts correctly (e.g., `00000001.WAV`, `00000002.WAV`)
- Each file should contain the same number of channels
- Files should be sequential parts of the same recording

### Output Files

The script creates individual WAV files for each channel:
- `CH1.wav` - Channel 1 (complete concatenated audio)
- `CH2.wav` - Channel 2
- `CH3.wav` - Channel 3
- ... up to the specified channel count

## Configuration Options

### Modifiable Variables in Script
```bash
CHUNK_PATTERN="*.WAV"      # File pattern to match
CHANNEL_COUNT=32          # Default number of channels
OUTPUT_PREFIX="CH"        # Output file prefix
```

### Runtime Options
- **Channel Count**: Specify during execution (supports any number)
- **Output Prefix**: Custom naming for output files
- **Input Folder**: Any directory containing your audio chunks

## Technical Details

### How It Works
1. **File Discovery**: Scans directory for WAV files and sorts them
2. **Filter Graph Construction**: Builds dynamic FFmpeg filter graphs for each channel
3. **Channel Extraction**: Uses FFmpeg's `channelmap` to isolate individual channels
4. **Concatenation**: Joins channel segments across all input files
5. **Output Generation**: Creates PCM S16LE WAV files for each channel

### FFmpeg Commands
The script generates FFmpeg commands like:
```bash
ffmpeg -i 00000001.WAV -i chunk2.WAV -filter_complex \
"[0]channelmap=0-0:mono[0_0];[1]channelmap=0-0:mono[0_1];\
[0_0][0_1]concat=n=2:v=0:a=1[out0]" -map "[out0]" -c:a pcm_s16le CH1.wav
```

## Error Handling

- **Folder Validation**: Checks if specified directory exists
- **File Detection**: Verifies audio files are present
- **Input Validation**: Validates numeric inputs for channel count
- **Process Monitoring**: Checks FFmpeg exit status for success/failure

## Troubleshooting

### Common Issues

1. **"No audio files found"**
   - Ensure files have `.WAV` extension (uppercase)
   - Check file permissions in the directory

2. **FFmpeg not found**
   - Install FFmpeg and ensure it's in your PATH
   - Verify with `ffmpeg -version`

3. **Permission denied**
   - Make script executable: `chmod +x script_name.sh`

4. **Processing errors**
   - Check `log.txt` for detailed FFmpeg commands and errors
   - Verify all input files have the same channel layout

### Log File
The script creates `log.txt` with:
- FFmpeg commands executed
- Debug information
- Error details (if any)

## Examples

### Basic Example
```bash
./chunk_extract.sh
# Uses current directory, 32 channels, "CH" prefix
```

### Custom Configuration
```bash
./chunk_extract.sh
# When prompted:
# - Folder: /path/to/audio/chunks
# - Channels: 16
# - Prefix: "DRUM_"
# Output: DRUM_1.wav through DRUM_16.wav
```

## License

[GNU GPLv3](LICENSE) Created by MatiqBushwick.

## Contributing

Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests

## Support

For issues and questions:
1. Check the troubleshooting section
2. Examine the `log.txt` file
3. Ensure FFmpeg is properly installed
4. Verify input file format and structure

---

**Note**: This script is designed for professional audio workflows and handles large multitrack sessions efficiently. Always backup your original files before processing.
