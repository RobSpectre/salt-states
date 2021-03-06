old-versions-ffmpeg:
  pkg.removed:
    - pkgs:
      - libav-tools
      - ffmpeg
      - yasm

ffmpeg-deps:
  pkg.latest:
    - pkgs:
      - x264
      - libx264-dev
      - libmp3lame-dev
      - autoconf
      - automake
      - build-essential
      - libass-dev
      - libgpac-dev
      - libtheora-dev
      - libtool
      - libvorbis-dev
      - pkg-config
      - texi2html
      - zlib1g-dev
      - libfaac-dev

yasm-tarball:
  file.managed:
    - name: /opt/yasm-source/yasm-1.2.0.tar.gz
    - source: http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
    - source_hash: md5=4cfc0686cf5350dd1305c4d905eb55a6
    - makedirs: True
    - require:
      - pkg: ffmpeg-deps 

yasm-source:
  cmd.wait:
    - name: tar -xzf /opt/yasm-source/yasm-1.2.0.tar.gz && echo "changed=True comment='YASM extracted.'"
    - stateful: True
    - cwd: /opt/yasm-source
    - require:
      - file: yasm-tarball
    - watch:
      - file: yasm-tarball

yasm-build:
  cmd.wait:
    - name: ./configure --prefix="/opt/ffmpeg-source/ffmpeg_build" --bindir="/usr/local/bin" && echo "changed=True comment='YASM configured.'"
    - stateful: True
    - cwd: /opt/yasm-source/yasm-1.2.0
    - watch:
      - cmd: yasm-source

yasm-compile:
  cmd.wait:
    - name: make && echo "changed=True comment='YASM compiled.'"
    - stateful: True
    - cwd: /opt/yasm-source/yasm-1.2.0
    - watch:
      - cmd: yasm-build

yasm-install:
  cmd.wait:
    - name: make install && echo "changed=True comment='YASM installed.'"
    - stateful: True
    - cwd: /opt/yasm-source/yasm-1.2.0
    - watch:
      - cmd: yasm-compile
    
yasm-clean:
  cmd.wait:
    - name: make distclean && echo "changed=True comment='YASM build cleaned.'"
    - stateful: True
    - cwd: /opt/yasm-source/yasm-1.2.0
    - watch:
      - cmd: yasm-install

ffmpeg-source:
  git.latest:
    - name: git://source.ffmpeg.org/ffmpeg
    - target: /opt/ffmpeg-source
    - rev: release/2.2 
    - submodules: True
    - force_clone: True
    - require:
      - pkg: ffmpeg-deps

ffmpeg-configure:
  cmd.wait:
    - name: ./configure --prefix="/opt/ffmpeg-source/ffmpeg_build" --extra-cflags="-I/opt/ffmpeg-source/ffmpeg_build/include" --extra-ldflags="-L/opt/ffmpeg-source/ffmpeg_build/lib" --bindir="/usr/local/bin" --extra-libs="-ldl" --enable-gpl --enable-libmp3lame --enable-libass --enable-libtheora --enable-libvorbis --enable-libx264 --enable-nonfree --enable-libfaac && echo "changed=True comment='ffmpeg reconfigured.'"
    - stateful: True
    - cwd: /opt/ffmpeg-source
    - env:
      PKG_CONFIG_PATH: $HOME/ffmpeg_build/lib/pkgconfig 
      PATH: "/opt/yasm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    - require:
      - git: ffmpeg-source
      - pkg: ffmpeg-deps
      - cmd: yasm-clean
    - watch:
      - git: ffmpeg-source

ffmpeg-build:
  cmd.wait:
    - name: make && echo "changed=True comment='ffmpeg recompiled.'"
    - stateful: True
    - cwd: /opt/ffmpeg-source
    - require:
      - git: ffmpeg-source
      - cmd: ffmpeg-configure
    - watch:
      - cmd: ffmpeg-configure

ffmpeg-install:
  cmd.wait:
    - name: make install && echo "changed=true comment='ffmpeg reinstalled.'"
    - stateful: True
    - cwd: /opt/ffmpeg-source
    - require:
      - git: ffmpeg-source
    - watch:
      - cmd: ffmpeg-build

ffmpeg-clean:
  cmd.wait:
    - name: make distclean && echo "changed=true comment='ffmpeg build cleaned.'"
    - stateful: True
    - cwd: /opt/ffmpeg-source
    - require:
      - git: ffmpeg-source
    - watch:
      - cmd: ffmpeg-install
