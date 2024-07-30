***Prepare Setup***
The "/etc/hosts" file must contain a fully qualified name for the server.
```
<IP-address>  <fully-qualified-machine-name>  <machine-name>
```
For example
```
vim /etc/hosts
10.30.21.12 prod-telco-db-api02.novalocal
```

Set the correct hostname in the "/etc/hostname" file.
```
prod-telco-db-api02.novalocal
```

**Automatic Setup**

If you plan to use the "oracle-database-preinstall-19c" package to perform all your prerequisite setup, issue the following command.
```
dnf install -y oracle-database-preinstall-19c
```
It is probably worth doing a full update as well, but this is not strictly speaking necessary.
```
dnf update -y
```

If you are using RHEL8 or CentOS8, you can pick up the RPM from the OL8 repository and install it. It will pull the dependencies from your normal repositories.
```
curl -o oracle-database-preinstall-19c-1.0-2.el8.x86_64.rpm https://yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/getPackage/oracle-database-preinstall-19c-1.0-2.el8.x86_64.rpm

dnf -y localinstall oracle-database-preinstall-19c-1.0-2.el8.x86_64.rpm
```

**Manual Setup**
**Step 1:**
```
dnf install -y bc \
binutils \
elfutils-libelf \
elfutils-libelf-devel \
fontconfig-devel \
glibc \
glibc-devel \
ksh \
libaio \
libaio-devel \
libXrender \
libXrender-devel \
libX11 \
libXau \
libXi \
libXtst \
libgcc \
librdmacm-devel \
libstdc++ \
libstdc++-devel \
libxcb \
make \
net-tools \
smartmontools \
sysstat \
unzip \
libnsl \
libnsl2
```

**Step 2:**
```
groupadd -g 1501 oinstall
groupadd -g 1502 dba
groupadd -g 1503 oper
groupadd -g 1504 backupdba
groupadd -g 1505 dgdba
groupadd -g 1506 kmdba
groupadd -g 1507 racdba
useradd -u 1501 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,racdba oracle
echo "oracle" | passwd oracle --XYZ
```

**Additional Setup**
Set the password for the "oracle" user.
```
passwd oracle
```

Set secure Linux to permissive by editing the "/etc/selinux/config" file, making sure the SELINUX flag is set as follows.
```
SELINUX=permissive
```

Once the change is complete, restart the server or run the following command.
```
setenforce Permissive
```

Create the directories in which the Oracle software will be installed.
```
mkdir -p /u01/app/oracle/product/19.3.0/dbhome_1
mkdir -p /u02/oradata
chown -R oracle:oinstall /u01 /u02
chmod -R 775 /u01 /u02
```

Set environment for Oracle
```
su - oracle
vi .bash_profile
# Oracle Settings
export TMP=/tmp
export TMPDIR=$TMP

export ORACLE_HOSTNAME=prod-telco-db-api02.novalocal
export ORACLE_UNQNAME=cdb1
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19.3.0/dbhome_1
export ORA_INVENTORY=/u01/app/oraInventory
export ORACLE_SID=oradbr
export PDB_NAME=pdb1
export DATA_DIR=/u02/oradata

export PATH=/usr/sbin:/usr/local/bin:$PATH
export PATH=$ORACLE_HOME/bin:$PATH

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
```
source .bash_profile

**Installation**

# Unzip software.
cd $ORACLE_HOME
unzip -oq /path/to/software/LINUX.X64_193000_db_home.zip

# Fake Oracle Linux 7.
export CV_ASSUME_DISTID=OEL7.8

# Silent mode
```
./runInstaller -ignorePrereq -waitforcompletion -silent \
oracle.install.option=INSTALL_DB_SWONLY \
ORACLE_HOSTNAME=${ORACLE_HOSTNAME} \
UNIX_GROUP_NAME=oinstall \
INVENTORY_LOCATION=${ORA_INVENTORY} \
ORACLE_HOME=${ORACLE_HOME} \
ORACLE_BASE=${ORACLE_BASE} \
oracle.install.db.InstallEdition=EE \
oracle.install.db.OSDBA_GROUP=dba \
oracle.install.db.OSBACKUPDBA_GROUP=backupdba \
oracle.install.db.OSDGDBA_GROUP=dgdba \
oracle.install.db.OSKMDBA_GROUP=kmdba \
oracle.install.db.OSRACDBA_GROUP=racdba \
SECURITY_UPDATES_VIA_MYORACLESUPPORT=e \
DECLINE_SECURITY_UPDATES=true
```
Run the root scripts when prompted.
```
As a root user, execute the following script(s):
        1. /u01/app/oraInventory/orainstRoot.sh
        2. /u01/app/oracle/product/19.0.0/dbhome_1/root.sh
```
**Database Creation:**
```
dbca -silent -createDatabase \
-templateName General_Purpose.dbc \
-gdbname ${ORACLE_SID} -sid  ${ORACLE_SID} \
-responseFile NO_VALUE \
-characterSet AL32UTF8 \
-sysPassword AsimGroUp#2023 \
-systemPassword AsimGroUp#2023 \
-createAsContainerDatabase true \
-numberOfPDBs 1 \
-pdbName ${PDB_NAME} \
-pdbAdminPassword V3ryStr@ng \
-databaseType MULTIPURPOSE \
-automaticMemoryManagement false \
-totalMemory 9800 \
-storageType FS \
-datafileDestination "${DATA_DIR}" \
-redoLogFileSize 50 \
-emConfiguration NONE \
-ignorePreReqs
```

refer: https://oracle-base.com/articles/19c/oracle-db-19c-installation-on-oracle-linux-8
