package haxe.net;
import haxe.io.Error;
import haxe.net.impl.SocketSys;
import haxe.net.impl.WebSocketGeneric;
import sys.net.Host;
import sys.ssl.Socket;
import sys.ssl.Certificate;
import sys.ssl.Key;

enum Security {
    Unsecured;
    UseCertificateFromFiles( caFile:String, certFile:String, keyFile:String, bVerifyCert: Bool );
}

class WebSocketServer { 

	var _isDebug      : Bool;
	var _isSecure     : Bool;
	var _listenSocket : sys.net.Socket;
	#if neko
	var keepalive     : Dynamic;
	#end

	function new(host:String, port:Int, maxConnections:Int, security:Security, isDebug:Bool=false) {
		_isDebug = isDebug;
		_listenSocket = _isSecure ? new sys.ssl.Socket() : new sys.net.Socket() ;
		
        switch security {
            case Unsecured: _isSecure = false;
            case UseCertificateFromFiles(caFile, certFile, keyFile, bVerifyCert):
                _isSecure = true;

                var sslSocket : sys.ssl.Socket = cast _listenSocket;
                sslSocket.setCA(Certificate.loadFile(caFile));
                sslSocket.setCertificate(
                    Certificate.loadFile(certFile), 
                    Key.readPEM(sys.io.File.getContent(keyFile), false)
                );
                sslSocket.verifyCert = bVerifyCert;
        }
		_listenSocket.bind(new Host(host), port);
		_listenSocket.setBlocking(false);
		_listenSocket.listen(maxConnections);
		
		#if neko
		keepalive = neko.Lib.load("std", "socket_set_keepalive",4);
		//disable keepalive:
		keepalive( @:privateAccess _listenSocket.__s, false, null, null );
		#end
	}
	
	public static function create(host:String, port:Int, maxConnections:Int, optionalCert:Security, isDebug:Bool) {
		return new WebSocketServer(host, port, maxConnections, optionalCert, isDebug);
	}
	
	public function accept():WebSocket {
		try {
			var socket:Dynamic = null;
			 if(_isSecure){
				socket = cast(_listenSocket, sys.ssl.Socket).accept();
			}else{
				socket = _listenSocket.accept();
			}
			return WebSocket.createFromAcceptedSocket(Socket2.createFromExistingSocket(socket, _isDebug), '', _isDebug);
		}
		catch (e:Dynamic) {
			
			return null;
		}
	}
	
}
