Read the following before using the files within this archive.

1. This archive contains source files that belong to the Icecast Player sample application posted on the Adobe Flash Player Developer Center: http://www.adobe.com/devnet/flashplayer/articles/icecast-streams.html


* Use these files with the article to build the sample Icecast Player application.


2. Instructions on building Icecast Player sample application for Flash Player 11

This package includes the following files:

src\com\icecastPlayer\Icecastplayer.as  - Main entry point. It manages loading, synchronization, and playback.
src\com\icecastPlayer\Flv.as - Creates the FLV header and audio tag header.
src\com\icecastPlayer\MpegHeader.as - Parses the MPEG header.
src\com\icecastPlayer\IcecastPlayerEvent.as - Defines playback status and error events.
ReadMe.txt - This file


1. Install Flash Builder 4.6
2. Please make sure that you have Flash Player 11 debug version installed (http://www.adobe.com/support/flashplayer/downloads.html)
3. Create a new Flex Library Project and name it icecastPlayer.
4. Replace the icecastPlayer/src folder located in the provided sample files.
5. Notice that the icecastPlayer/bin/icecastPlayer.swc is generated automatically.
6. Create a new ActionScript Project and name it icecastPlayerApp.
7. In the properties of the icecastPlayerApp, select ActionScript Build Path pane. Click the "Add SWC..." button and specify the icecastPlayer.swc generated in Step 5.
8. Add the following source code to icecastPlayerApp.as file:
package
{
  import com.icecastplayer.IcecastPlayer;
  import flash.net.URLRequest;
  import flash.display.Sprite;

  public class icecastPlayerApp extends Sprite
  {
    public function icecastPlayerApp()
    {
      var player:IcecastPlayer = new IcecastPlayer(new URLRequest("http://media.example.com/stream.mp3"));
      player.play();
    }
  }
}
7. Specify the URL of an Icecast stream. Visit the Icecast Directory (http://dir.xiph.org/index.php) to obtain sample streams. You can select any URL in the M3U playlist file for this sample project.


After these steps, run the application and you should hear audio playing.

