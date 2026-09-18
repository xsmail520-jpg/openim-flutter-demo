package io.openim.network;

import android.util.Log;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Collections;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import javax.net.ssl.SNIHostName;
import javax.net.ssl.SSLParameters;
import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;

/**
 * Wraps Xray's local WebSocket connection in Android system TLS. Some carrier
 * networks reset the identifiable Go/Xray TLS fingerprint while allowing the
 * platform TLS stack used by normal Android apps.
 */
final class AppTlsTunnel {
    private static final String LOG_TAG = "OpenImTlsTunnel";

    private final String remoteHost;
    private final String remoteAddress;
    private final int remotePort;
    private final int localPort;
    private final ExecutorService acceptor = Executors.newSingleThreadExecutor();
    private final ExecutorService connections = Executors.newCachedThreadPool();
    private volatile ServerSocket serverSocket;

    AppTlsTunnel(String remoteHost, String remoteAddress, int remotePort, int localPort) {
        this.remoteHost = remoteHost;
        this.remoteAddress = remoteAddress;
        this.remotePort = remotePort;
        this.localPort = localPort;
    }

    void start() throws IOException {
        ServerSocket server = new ServerSocket();
        server.setReuseAddress(true);
        // Xray outbound explicitly dials IPv4; some emulators resolve the generic
        // loopback address to ::1 and would otherwise refuse 127.0.0.1.
        server.bind(new InetSocketAddress(InetAddress.getByName("127.0.0.1"), localPort));
        serverSocket = server;
        acceptor.execute(() -> acceptLoop(server));
    }

    void stop() {
        ServerSocket server = serverSocket;
        serverSocket = null;
        closeQuietly(server);
        acceptor.shutdownNow();
        connections.shutdownNow();
    }

    private void acceptLoop(ServerSocket server) {
        while (!server.isClosed()) {
            try {
                Socket local = server.accept();
                connections.execute(() -> bridge(local));
            } catch (IOException error) {
                if (!server.isClosed()) {
                    Log.w(LOG_TAG, "accept failed: " + error.getClass().getSimpleName());
                }
            }
        }
    }

    private void bridge(Socket local) {
        SSLSocket remote = null;
        try {
            local.setTcpNoDelay(true);
            remote = (SSLSocket) SSLSocketFactory.getDefault().createSocket();
            SSLParameters parameters = remote.getSSLParameters();
            parameters.setEndpointIdentificationAlgorithm("HTTPS");
            parameters.setServerNames(Collections.singletonList(new SNIHostName(remoteHost)));
            remote.setSSLParameters(parameters);
            // Bootstrap with the VLESS node's address. DNS is not reliable on
            // the emulator during tunnel startup, while SNI still remains the
            // service hostname for certificate and virtual-host selection.
            remote.connect(new InetSocketAddress(remoteAddress, remotePort), 8_000);
            remote.startHandshake();
            remote.setTcpNoDelay(true);

            SSLSocket activeRemote = remote;
            connections.execute(() -> copy(local, activeRemote));
            copy(activeRemote, local);
        } catch (IOException error) {
            Log.w(LOG_TAG, "bridge failed: " + error.getClass().getSimpleName());
        } finally {
            closeQuietly(local);
            closeQuietly(remote);
        }
    }

    private static void copy(Socket source, Socket destination) {
        try {
            InputStream input = source.getInputStream();
            OutputStream output = destination.getOutputStream();
            byte[] buffer = new byte[32 * 1024];
            int read;
            while ((read = input.read(buffer)) != -1) {
                output.write(buffer, 0, read);
                output.flush();
            }
        } catch (IOException ignored) {
            // Closing either half tears down the paired connection.
        } finally {
            closeQuietly(source);
            closeQuietly(destination);
        }
    }

    private static void closeQuietly(java.io.Closeable value) {
        if (value == null) return;
        try {
            value.close();
        } catch (IOException ignored) {
            // Idempotent lifecycle cleanup.
        }
    }
}
