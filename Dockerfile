FROM mysql:5.6.49

ARG MROONGA_VERSION=9.12
ARG MYSQL_SOURCE_VERSION=5.6.49
ARG MYSQL_MAJOR_VERSION=5.6

RUN apt-get update && apt-get install -y apt-utils apt-transport-https dpkg-dev \
  && apt-get install -y --no-install-recommends bison cmake libncurses5-dev libssl-dev zlib1g-dev wget \
  # groongaのアーカイブ取得&インストール
  && wget https://packages.groonga.org/debian/groonga-archive-keyring-latest-stretch.deb \
  && apt-get install -y -V ./groonga-archive-keyring-latest-stretch.deb \
  && echo "deb-src http://repo.mysql.com/apt/debian/ stretch mysql-${MYSQL_MAJOR_VERSION}" >> /etc/apt/sources.list.d/mysql.list \
  # groongaインストール&ビルド
  && apt-get update \
  && apt-get install -y --allow-unauthenticated groonga-keyring \
  && apt-get update \
  && apt-get install -y --no-install-recommends libgroonga-dev groonga-normalizer-mysql groonga-tokenizer-mecab \
  # もしかしたらいらないかも
  && chown -Rv _apt:root /var/cache/apt/archives/partial/ \
  && chmod -Rv 700 /var/cache/apt/archives/partial/ \
  # MySQLソースインストール
  && cd /usr/src \
  && apt-get source mysql-community-source \
  && mkdir -p ./mysql-community-${MYSQL_SOURCE_VERSION}/build \
  && cd /usr/src/mysql-community-${MYSQL_SOURCE_VERSION}/build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr -DINSTALL_PLUGINDIR=lib/mysql/plugin \
  -DDOWNLOAD_BOOST=1 -DDOWNLOAD_BOOST_TIMEOUT=1800 -DWITH_BOOST=/usr/src/boost .. \
  &&  make \
  && cd libservices && make install \
  # mroongaインストール&ビルド
  && cd /usr/src \
  && wget https://packages.groonga.org/source/mroonga/mroonga-${MROONGA_VERSION}.tar.gz \
  && tar xzf mroonga-${MROONGA_VERSION}.tar.gz \
  && cd mroonga-${MROONGA_VERSION} \
  && ./configure --prefix=/usr \
  --with-mysql-source=/usr/src/mysql-community-${MYSQL_SOURCE_VERSION} \
  --with-mysql-build=/usr/src/mysql-community-${MYSQL_SOURCE_VERSION}/build \
  --with-mysql-config=/usr/src/mysql-community-${MYSQL_SOURCE_VERSION}/build/scripts/mysql_config \
  && make install \
  # MySQL Docker起動時にmroongaがインストールされるように設定
  && ln -s /usr/share/mroonga/install.sql /docker-entrypoint-initdb.d/mroonga-install.sql \
  # ビルド用パッケージをアンインストール
  && apt-get purge -y --auto-remove dpkg-dev bison cmake libncurses5-dev libssl-dev zlib1g-dev wget \
  # 不要なファイルを削除
  && rm -rf /usr/src/* /var/lib/apt/lists/*
