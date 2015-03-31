NAME=opencv
VERSION=3.0.0-beta
WORKDIR=/tmp/

pushd ${WORKDIR}

if [ ! -d ${NAME}-${VERSION} ]; then
    wget https://github.com/Itseez/${NAME}/archive/${VERSION}.tar.gz
    openssl sha1 ${VERSION}.tar.gz # 560895197d1a61ed88fab9ec791328c4c57c0179
    tar xf ${VERSION}.tar.gz
fi

cd ${NAME}-${VERSION}
python platforms/ios/build_framework.py ios

popd
