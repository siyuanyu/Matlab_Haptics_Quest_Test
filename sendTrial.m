%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   
%   sendTrial - Sends an array of trial information to correseponding TPad
%   Phone application for Haptics 495, Winter 2017.
%
%   Usage:
%   response = sendTrial([wlA wlB wlC wlD Trial#]);  
%       wlA-D: wavelength of corresponding sinusoidal grating, in mm.
%       Trial#: number displayed as trial number in app.
%       response: returns 1 if data sent successfully, 0 if retries fail.
%
%   Example:
%   sendTrial([0 2 3 4 1]);
%   This would set Grating A blank, Grating B to a 1mm wavelength sinusoid,
%   Grating C to 3mm wl, Grating D to 4 mm wl, and the trial number to 1. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function response = sendTrial(message)

    import java.net.ServerSocket
    import java.io.*
   
    number_of_retries = 10; % set to -1 for infinite
    retry             = 0;

    server_socket  = [];
    output_socket  = [];    
    
    output_port = 23399;

    while true

        retry = retry + 1;

        try
            if ((number_of_retries > 0) && (retry > number_of_retries))
                fprintf(1, 'Too many retries\n');
                response = 0;
                break;
            end

            if(length(message) ~= 5)
                fprintf(1, 'Please send an array of 5 numbers.\n'); 
                fprintf(1, '[wlA, wlB, wlC, wlD, trial#]\n');
                fprintf(1, 'Send wl in units mm. Send wl 0 if not in use.\n');
                response = 0;
                break;
            end
            
            strmessage = num2str(message, 4);            
            
            fprintf(1, ['Try %d waiting for client to connect to this ' ...
                        'host on port : %d\n'], retry, output_port);

            % wait for 1 second for client to connect server socket
            server_socket = ServerSocket(output_port);
            server_socket.setSoTimeout(1000);

            output_socket = server_socket.accept;

            fprintf(1, 'Client connected\n');

            output_stream   = output_socket.getOutputStream;
            d_output_stream = DataOutputStream(output_stream);

            % output the data over the DataOutputStream
            % Convert to stream of bytes
            % fprintf(1, 'Writing %d bytes\n', length(strmessage))
            d_output_stream.writeBytes(char(strmessage));
            d_output_stream.flush;
            fprintf(1, 'Data Sent\n', length(strmessage))
            response = 1;
            
            % clean up
            server_socket.close;
            output_socket.close;
            break;
            
        catch
            if ~isempty(server_socket)
                server_socket.close
            end

            if ~isempty(output_socket)
                output_socket.close
            end

            % pause before retrying
            pause(1);
        end
    end
end