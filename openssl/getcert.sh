#!/usr/bin/bash
#
# Generate a set of TLS credentials that can be used to run development mode.
# Author Laxman singh jodhpur.laxman@gmail.com
# usage: sh ./genkeys.sh NAME HOSTNAME IP

set -o errexit

USAGE="usage: sudo ./genkeys.sh NAME HOSTNAME IP"
ROOT="$(pwd)"
ROOT1=${ROOT}
PASSFILE="${ROOT}/dev.password"
PASSOPT="file:${ROOT}/dev.password"
CAFILE="${ROOT}/ca-bundle.pem"
CAKEY="${ROOT}/ca-key.pem"

# Randomly create a password file, if you haven't supplied one already.
# For development mode, we'll just use the same (random) password for everything.
if [ ! -f "${PASSFILE}" ]; then
  echo ">> creating a random password in ${PASSFILE}."
  touch ${PASSFILE}
  chmod 600 ${PASSFILE}
  # "If the same pathname argument is supplied to -passin and -passout arguments then the first
  # line will be used for the input password and the next line for the output password."
  cat /dev/random | head -c 128 | base64 | sed -n '{p;p;}' >> ${PASSFILE}
  echo "<< random password created"
fi

# Generate the certificate authority that we'll use as the root for all the things.
if [ ! -f "${CAFILE}" ]; then
  echo ">> generating a certificate authority"
  mkdir -p /etc/ssl/selfsigned/
  openssl genrsa -des3 \
    -passout ${PASSOPT} \
    -out ${CAKEY} 2048
  openssl req -new -x509 -days 3650 \
    -batch \
    -passin ${PASSOPT} \
    -key ${CAKEY} \
    -passout ${PASSOPT} \
    -out ${CAFILE} \
    -subj "/C=US/ST=NewYork/L=New York co/O=Qualdev Inc./CN=Qualdev Inc."
fi
keypair() {
  local NAME=$1
#  local DOMAIN2=*.$2
  local SERIALOPT=""
  if [ ! -f "${ROOT}/ca.srl" ]; then
    echo ">> creating serial"
    SERIALOPT="-CAcreateserial"
  else
    SERIALOPT="-CAserial ${ROOT}/ca.srl"
  fi

  echo ">> generating a keypair for: ${NAME}"
  echo ""
  echo ""
   openssl genrsa -des3 \
    -passout ${PASSOPT} \
    -out ${ROOT}/${NAME}-key.pem 2048  > /dev/null 2>&1
   
cp ${ROOT}/server.csr.cnf ${ROOT}/openssl-${NAME}.cnf
echo "CN = ${NAME}" >> ${ROOT}/openssl-${NAME}.cnf
cp ${ROOT}/v3.ext  ${ROOT}/v3-${NAME}.ext
echo "DNS.1 = ${NAME}" >> ${ROOT}/v3-${NAME}.ext
echo "DNS.2 = www.${NAME}" >> ${ROOT}/v3-${NAME}.ext


openssl req -new -sha256 -nodes -out $ROOT/${NAME}.csr -newkey rsa:2048 -keyout ${ROOT1}/${NAME}.key -config <(cat $ROOT/openssl-${NAME}.cnf ) > /dev/null 2>&1
openssl x509 -req -in $ROOT/${NAME}.csr -CA ${CAFILE} -CAkey ${CAKEY} -passin ${PASSOPT} -CAcreateserial -out ${ROOT1}/${NAME}.crt -days 500  -sha256 -extfile $ROOT/v3-${NAME}.ext > /dev/null 2>&1
cp ${CAFILE} /etc/ssl/selfsigned/
cp  ${ROOT1}/${NAME}.crt  /etc/ssl/selfsigned/
cp ${ROOT1}/${NAME}.key /etc/ssl/selfsigned/

rm -rf ${ROOT}/${NAME}-key.pem ${ROOT1}/${NAME}.crt $ROOT/v3-${NAME}.ext  $ROOT/openssl-${NAME}.cnf $ROOT/${NAME}.csr
}
if [ -z "$1" ]; then
  echo "${USAGE}"
  exit 1
fi
keypair "$1"

  
