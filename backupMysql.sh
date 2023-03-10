#!/bin/bash
#
### Parametros do script ###
BACKUP_DATE_DIR="`date +%Y/[%m]-%b/%d-%a`"
BACKUP_DATABASE="cesarjorge17"
BACKUP_NAME="$BACKUP_DATABASE-`date +%d.%b.%Y-%Hh`"     # Nome que ficara o backup. Ex: backup-SERVER01-01_12_2015
#
BACKUP_PATH="/root/dropbox"                             # Local do diretorio do script
BACKUP_TEMP="$BACKUP_PATH/tmp"                          # Local temporario dos backups
BACKUP_SCRIPT="/opt/bkpSync/backupMysql.sh"             # Shell do backup
#
STORAGE_LOCAL="/root/dropbox/backup"                    # Diretorio local
REMOTE_RAIZ="/BACKUPS/MYSQL/HERPIA"                     # Diretorio Raiz do Backup
STORAGE_FILE_LOCAL="$STORAGE_LOCAL/$BACKUP_DATE_DIR"    # Diretorio Remoto (Drop Box)
#
PERMISSIONS=`stat -c %a $BACKUP_SHELL 2>&1`             # Pega as permissoes do shell
RCLONE=$(which rclone)  		                # Executavel RCLONE
RCLONE_KEY="backupt3"                                   # Chave Rclone criada com o comando "rclone config"
#
LOG_FILE="/var/log/mysql-backup.log"                    # Local dos logs
USER="root"                                             # Usuario do backup
SECRET="Agoravai@2017"					# Senha do usuario

### Nao editar abaixo ###

# Verifica se o nome do backup nao e nulo
if [ -z $BACKUP_NAME ]; then
        echo -e "\n\tERRO: Variavel BACKUP_NAME contem valor nulo"
        echo  "`date` - ERRO: Variavel BACKUP_NAME contem valor nulo" >> $LOG_FILE
        exit 1
fi
# Verifica se o local configurado esta correto
if [ ! -d $BACKUP_PATH ]; then
        echo -e "\n\tERRO: Variavel BACKUP_PATH esta incorreta, o local de instalacao nao existe"
        echo "`date` - ERRO: Variavel BACKUP_PATH esta incorreta, o local de instalacao nao existe" >> $LOG_FILE
        #exit 1
fi
# Verifica se o local temporario existe
if [ ! -d $BACKUP_TEMP ]; then
        echo -e "\n\tERRO: Variavel BACKUP_TEMP esta incorreta, o local de backup nao existe"
        echo "`date` - ERRO: Variavel BACKUP_TEMP esta incorreta, o local de backup nao existe" >> $LOG_FILE
        exit 1
fi
if [ ! -f $BACKUP_SHELL ]; then
        echo -e "\n\tERRO: O shell MySQL_Backup.sh nao foi encontrado"
        echo "`date` - ERRO: O shell MySQL_Backup.sh nao foi encontrado" >> $LOG_FILE
        exit 1
fi
# Verifica se a permissao do shell esta correta
if [ $PERMISSIONS != "700" ]; then
        echo -e "\n\tERRO: Permissao do arquivo $BACKUP_SHELL incorreta! Permissao deve ser 700"
        echo "`date` - ERRO: Permissao do arquivo $BACKUP_SHELL incorreta! Permissao deve ser 700" >> $LOG_FILE
        exit 1
fi
# Verifica se o usuario nao e nulo
if [ -z $USER ]; then
        echo -e "\n\tERRO: Usuario nao configurado"
        echo "`date` - ERRO: Usuario nao configurado" >> $LOG_FILE
        exit 1
fi
#Verifica se a senha nao e nula
if [ -z $SECRET ]; then
        echo -e "\n\tERRO: A senha do usuario $USER nao foi fornecida"
        echo "`date` - ERRO: A senha do usuario $USER nao foi fornecida" >> $LOG_FILE
        exit 1
fi

# Cria estrutura de diretorios de backup localmente
CreateDirs(){
  mkdir -p $STORAGE_LOCAL/$BACKUP_DATE_DIR
}
# Funcao que consulta todos os bancos do seu servidor e faz o backup
GetDatabases(){
#       for DB in `mysql -u$USER -p$SECRET -e "SHOW DATABASES"|grep -v Database`; do
        for DB in `mysql -u$USER -p$SECRET -e "SHOW DATABASES"|grep $BACKUP_DATABASE`; do
                echo "`date`  -  Fazendo backup do banco $DB"
                mysqldump -u$USER -p$SECRET  $DB > $BACKUP_TEMP/$DB.sql
        done
}
# Funcao que compact dos backups
ZipDatabases(){
        cd $BACKUP_TEMP
	zip $BACKUP_NAME.zip *.sql
}
# Funcao que faz o upload do backup
CopyDbZip(){
	echo "Copia arquivo Zipado para DIR backup LOCAL"
        cp $BACKUP_TEMP/*.zip $STORAGE_FILE_LOCAL >> $LOG_FILE 2>&1
}
UploadDbfromRclone(){
        $RCLONE --log-file=rclone.log -v -P sync $STORAGE_LOCAL $RCLONE_KEY:$REMOTE_RAIZ
        rm -rf $BACKUP_TEMP/*
}
SendTelegram(){
	API_TOKEN=""
	ID=""
	API_TOKEN=""
	ID=""
	#ID=""
	LOG="/var/log/telegram.log"
 	HORA=$(echo $BACKUP_NAME | cut -c 26-27)
	HEADER=">> Backup 'HARPIA' $HORA"h" 💾 <</n"
	ListSMB=$(ls -lh "$STORAGE_LOCAL/$BACKUP_DATE_DIR" | grep $HORA":" | awk '{printf "%1s %s\n", $5," "$9}')
	if [ -z "$ListSMB" ]; then
		MSGSMB="Arquivo não encontrado ❌"
	else 
		MSGSMB="  ✅ "
	fi
        MESSAGE="$HEADER/nARQUIVO = $ListSMB $MSGSMB"
	MESSAGE=`echo $MESSAGE | sed 's/\/n/%0A/g'`
	URL="https://api.telegram.org/bot${API_TOKEN}/sendMessage?chat_id=${ID}&text=$MESSAGE"
	COUNT=1

   while [ $COUNT -le 20 ]; do

   echo "$(date +%d/%m/%Y\ %H:%M:%S) - Start message send (attempt $COUNT) ..." >> $LOG
   #echo "$(date +%d/%m/%Y\ %H:%M:%S) - $MESSAGELOG" >> $LOG
   #/usr/bin/curl -s "$URL" > /dev/null
   /usr/bin/curl -s "$URL"
	RET=$?

   if [ $RET -eq 0 ]; then
     echo "$(date +%d/%m/%Y\ %H:%M:%S) - Attempt $COUNT executed successfully!" >> $LOG
     exit 0
   else
     echo "$(date +%d/%m/%Y\ %H:%M:%S) - Attempt $COUNT failed!" >> $LOG
     echo "$(date +%d/%m/%Y\ %H:%M:%S) - Waiting 30 seconds before retry ..." >> $LOG
     sleep 30
     (( COUNT++ ))
   fi

done
}

GetDatabases >> $LOG_FILE 2>&1
ZipDatabases
CreateDirs
CopyDbZip
UploadDbfromRclone
SendTelegram
