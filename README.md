# Remote Logout PowerShell Script

This PowerShell script allows you to remotely check active logins on a Windows server and perform remote logout operations on specific users or multiple servers using a list file.

## Requirements

- Windows operating system
- PowerShell

## Usage

1. Clone or download the script files from this repository.

2. Place the `remote_logout.ps1` script file in a folder.

3. Ensure that the `list.txt` file is located in the same folder as the script. The `list.txt` file should contain a list of server names, each on a separate line, where you want to perform remote logout operations.

4. Open PowerShell and navigate to the folder where you placed the script file.

5. Run the script by executing the following command:
   ```
   ./remote_logout.ps1
   ```

6. Follow the on-screen instructions to perform the desired operations.

## Features

- Check active logins on a Windows server.
- Remotely logout a specific user on a server.
- Perform remote logout on multiple servers using the `list.txt` file.
- Error handling and server reachability checks.
- Logging of script operations, successes, and failures.

## Configuration

You can customize the behavior of the script by modifying the following variables:

- `$listFile`: Specifies the path to the `list.txt` file.

## Logging

The script logs all output to a log file named `RemoteLogoutLog.txt`. The log file is located in the same folder as the script. If the file already exists, the script appends new logs to it; otherwise, it creates a new log file.

## License

This script is licensed under the [MIT License](LICENSE).

Feel free to modify and adapt the script to suit your needs.

## Contributions

Contributions to this script are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.
