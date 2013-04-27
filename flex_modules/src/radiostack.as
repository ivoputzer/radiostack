package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.Socket;
	import flash.system.Security;
	
	public class radiostack extends Sprite
	{
		private var regexp :RegExp = /(?P<protocol>[a-zA-Z]+):\/\/(?P<host>[^:\/]*)(:(?P<port>\d+))?((?P<path>[^?]*))?((?P<query>.*))?/ix

		private var stream :Socket;
		
		private var schema :Object;
							
		public function log (method :String, message :String):void 
		{
			ExternalInterface.call("console.log", "fl : " + method + " > " + message );
		}
	
		public function radiostack ()
		{
			log("system", "swf file loaded...");

			log("system", "sandbox type : " + Security.sandboxType );
					
			lookup ("http://listen.radionomy.com/bestradio"); // send the onload to javascript +  for now lets fake a request
		}
		
		private var headers :String;
		
		private var metaint :int;
		
		public function lookup ( uri : String ) :void // this one should be accessible from javascript
		{
			try {
				
				schema = regexp.exec(uri); schema.port = int(schema.port) || 80;
											
				Security.loadPolicyFile(schema.protocol +"://"+ schema.host +":"+ schema.port +"/crossdomain.xml"); log("lookup","loading crossdomain file...");
				
				headers = ""; metaint = 0; // resetting some values to default
				
				with( stream = new Socket ){ addEventListener(Event.CONNECT, connect); addEventListener(Event.CLOSE, close); addEventListener(ProgressEvent.SOCKET_DATA, data); addEventListener(IOErrorEvent.IO_ERROR, error); addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityerror) }
				
				stream.connect (schema.host, schema.port); log("lookup","connecting to socket server...");		
			}
			catch (e:Error) { stream.close(); log("lookup","socket exception " + e) }	
		}
		
		private function connect(e:Event):void
		{
			var headers :String = "GET " + schema.path + schema.query + " HTTP/1.1\r\nUser-Agent: WinampMPEG/2.9\r\nAccept: */*\r\nHost: "+ schema.host +"\r\nIcy-MetaData: 1\r\nConnection: Close\r\n\r\n";
			
			stream.writeUTFBytes(headers); log("connect","request headers\n\n" + headers);
		}
								
		private var counter :int = 0; // instead of totalbytes
		
		private var metastr :String = "";
		
		private var metalen : int = 0; // targetbyte - metalength
					
		private function data ( e :ProgressEvent ) :void
		{		
			try {
							
				if ( stream.bytesAvailable && headers.length == 0 )
				{	
					headers = stream.readUTFBytes(stream.bytesAvailable); log("data", "response headers\n\n" + headers);
					
					var matches :Array = headers.match(/icy-metaint\s*:\s*([^\s]+)/i);
					
					if ( matches ) metaint = int( matches.pop() );
					
					return;
				}
				
				while ( stream.bytesAvailable )
				{
					var byte : int = stream.readUnsignedByte(); counter++;
									
					if ( counter > metaint  )
					{
						if ( counter == (metaint + 1) )
						{
							log("debugging metalen", "byte:" + byte.toString() + "| len: " + byte * 16); metalen = byte * 16; continue;
						}
						
						if ( metastr.length < metalen ) { metastr += String.fromCharCode(byte); continue; }
									
						log("WE GOT IT! META INFORMATION IS", metastr.match(/streamtitle='\s*(.*)\s*';/i).pop() );
						
						stream.close(); return;
					}
				}
			}
			catch ( e:Error )
			{
				log ("data exception", e.toString() ); return; // if any error occurs just return 				
			}
		}
		
		private function close(e:Event):void
		{
			if ( stream.connected ) stream.close(); // security error fires if we dont
			
			if ( metaint == 0 ) // redirecting page usually does not provie icy-metaint header
			{
				var matches : Array = headers.match(/location\s*:\s*([^\s]+)/i); 
				
				if ( matches ) lookup( matches.pop() );
			}
		}
		
		private function error(e:IOErrorEvent) :void { log("error", e.toString() ) }
		
		private function securityerror(e:SecurityErrorEvent) :void { log("security error", e.toString() ) }
	}
}