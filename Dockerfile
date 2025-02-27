FROM rippled.azurecr.io/ax-rippled-node-deps:ubuntu2204

WORKDIR /opt

COPY external/rippled /opt/rippled

ENV LD_LIBRARY_PATH=/usr/local/lib/python3.10/dist-packages/xrpl_plugin

# Create build folder
WORKDIR /opt/build

# Build rippled executable
RUN conan install ../rippled --build missing --settings build_type=Debug && \
    cmake -DCMAKE_TOOLCHAIN_FILE=build/generators/conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Debug /opt/rippled -Dtests=Off && \
    cmake --build . --parallel 4

# Create directories for rippled.cfg, validators.txt and SSL certificates
RUN mkdir /etc/opt/ripple
RUN mkdir /etc/opt/ripple/private
RUN mkdir /etc/opt/ripple/certs

# Create directory for rippled DB and logs
RUN mkdir -p /var/lib/rippled/db/nudb
RUN mkdir -p /var/log/rippled

# Create rippled user and group
RUN groupadd -g 10001 rippled && \
   useradd -u 10000 -g rippled rippled

# Change ownership to rippled user
RUN chown rippled:rippled -R /etc/opt/ripple
RUN chown rippled:rippled -R /var/lib/rippled/db
RUN chown rippled:rippled -R /var/log/rippled
RUN chown rippled:rippled -R /opt/rippled
RUN chown rippled:rippled -R /opt/build

# Install xrpl-plugin library
RUN pip install xrpl-plugin -v

WORKDIR /opt

COPY ./python/examples/token_swap.py .
RUN plugin-build token_swap.py

# Clear conan cache
RUN conan remove "*" -f

# Copy entrypoint.sh script
COPY entrypoint.sh /home/rippled/entrypoint.sh

# Change ownership to rippled user
RUN chown rippled:rippled /home/rippled/entrypoint.sh

# Create symbolic link to rippled executable
RUN ln -s /opt/build/rippled /usr/local/bin/rippled

# Start container as rippled user
USER rippled:rippled

ENTRYPOINT [ "/home/rippled/entrypoint.sh" ]