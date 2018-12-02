# Programa busca todos os dispositivos conectado na rede Windows Ethernet ou wifi

Nesse aplicativo te permite localizar o Nome do PC, IP e MAC, salvando em um arquivo ".txt".

## Fundamentação

Houve a necessidade de se obter MAC e IP's de uma determinada situação, com vários PC's no ambiente,
sendo assim, facilitando a coleta de todas as informações via software.

## Caractrísticas

* Simples,
* Usa API do WIndows,
* Leve, < 15 MB,
* Caso tenha rede diferentes, basta fazer a troca da rede via (porta "VLAN") no Switch;

## Requisitos

* Em certos casos, deve desabilitar o Firewall da máquina.
* Conexão TCP/IP válida com IP válido.
* Máquinas com conexão ativa(conectado/ligada)
* Funciona apenas com Gateway usando DHCP (Automático), isto é com atribuições de ips automáticas.


## Funcionamento do programa

É realizada via API do windows manipulações de comnandos de rede via CMD

* 1ª Etapa: Gera um comando NET VIEW para listar todos os dispositivo (pelo nome).
  Me retorna o nome dos dispositivos na rede.
* 2ª Etapa: Faz uma busca do IP pelo nome, EX: ping -4 localhost,me retornando um IPV4 válido. 
  Me retorna o IPV4 do dispositivos na rede.
  
  Exemplo:
```pascal
  cmd := 'ping -4 ' + ip;
```
	
* 3ª Etapa: Faz uma consulta na tabela ARP retornando o MAC, EX: arp -a 127.0.0.1, me retornará o MAC do dispositivo
  Me retorna o MAC do dispositivos na rede.
  Exemplo:
```pascal 
 cmd := 'arp -a ' + ip;
```




