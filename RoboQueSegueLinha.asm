# Trabalho Final AOC 2019.2
# Professora Denise Stringhini
# UNIFESP - ICT - SJC
# Beatriz Martins Angelo 120202
# Claudio Jorge Lopes Filho 120223
# Israel da Rocha 120432

# Display config:
# 	Unit Width:	32
# 	Unit Height:	32
# 	Display Width:	512
# 	Display Height:	512
# 	Base Addres:	0x10040000 (heap)


.text
	.eqv preto, $s7
	.eqv pos_atual, $s0
	.eqv pos_inicial, $s1
	.eqv vermelho, $s2
	.eqv azul, $s3
	.eqv pilha1, $sp
	.eqv pilha2, $fp

.main:	
	lui $s0, 0x1004		# Pos atual
	lui $s1, 0x1004 	# Pos inicial
	li $s2, 0x00FF0000 	# Cor Vermelha
	li $s3, 0x7FFFD4	# Cor Azul - Robo
	addi $sp, $s1, 1024 	# Pos inicial pilha1
	addi $fp, $sp, 1024	# Pos atual pilha 2

	# Gera numero aleatorio de 0 a 255 e salva em pos_atual
	li $v0, 42 
	li $a1, 255
	syscall
	move $s4, $a0
	
	# Multiplica o numero por 4 (bits)
	add $s4, $s4, $s4
	add $s4, $s4, $s4
	add pos_atual, pos_atual, $s4
	
	# Pinta de vermelho a posicao armazenada em $t0 (Bitmap Display)
	sw vermelho, (pos_atual)
	
	# Atualiza pilhas
	addi pilha1, pos_atual, 1024
	sw $zero, (pilha1) 		#armazena indice na pilha1
	sw pos_atual, (pilha2) 		#armazena posicao na pilha2
	addi pilha2, pilha2, 4
	
	# Chama a funcao "labirinto" para criar a linha a ser seguida pelo robo
	li $s4, 1
	li $s5, 31 
	
	# Para criar uma linha de tamanho 30
	laco:
		# Delay
		#li $v0, 32
		#li $a0, 40
		#syscall
		beq $s4, $s5, continue 
		jal labirinto
		addi $s4, $s4, 1
		#addi $s6, $s6, 1
		j laco
		
	continue:
		
		#jal gera_robo
		jal pintaRobo
		jal procura
		jal percorre
		
	# Encerra o programa
	fim:
		li $v0, 10
		syscall

labirinto:
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
		
	# Gera um numero aleatorio de 0 a 3 e salva em pos_atual
	# 4 posicoes possiveis de quadrados adjacentes ao que ja esta pintado
	setup:
		li $v0, 42
		li $a1, 4
		syscall
		move $t0, $a0

		# Compara o numero gerado e vai para a funcao correspondente
		beq $t0, 0, pZero # Esquerda
		beq $t0, 1, pUm   # Direita
		beq $t0, 2, pDois # Baixo
		beq $t0, 3, pTres # Cima

	pZero:
		j checa_loop # Verifica se ja existe linha nos pixels adjacentes
		voltaZero:
			sne $t6, $t2, 1
			bne $t2, 1, setup
			addi pos_atual, pos_atual, -4 # Subtrai 4 bits para ir para o quadrado da esquerda
			sw vermelho, (pos_atual)
			
			#Atualiza pilhas
			addi pilha1, pos_atual, 1024
			sw $s4, (pilha1) #armazena indice na pilha1
			sw pos_atual, (pilha2) #armazena posicao na pilha2
			addi pilha2, pilha2, 4
			
			j end

	pUm:
		j checa_loop # Verifica se ja existe linha nos pixels adjacentes
		voltaUm:
			sne $t7, $t2, 1
			bne $t2, 1, setup
			addi pos_atual, pos_atual, 4 # Soma 4 bits para ir para o quadrado da direita
			sw vermelho, (pos_atual)
			
			# Atualiza pilhas
			addi pilha1, pos_atual, 1024
			sw $s4, (pilha1) #armazena indice na pilha1
			sw pos_atual, (pilha2) #armazena posicao na pilha2
			addi pilha2, pilha2, 4
			
			j end

	pDois:
		j checa_loop # Verifica se ja existe linha nos pixels adjacentes
		voltaDois:
			sne $t8, $t2, 1
			bne $t2, 1, setup
			addi pos_atual, pos_atual, 64 # Soma 64 bits para ir para o quadrado abaixo
			sw vermelho, (pos_atual)
			
			# Atualiza pilhas
			addi pilha1, pos_atual, 1024
			sw $s4, (pilha1) #armazena indice na pilha1
			sw pos_atual, (pilha2) #armazena posicao na pilha2
			addi pilha2, pilha2, 4
			
			j end

	pTres:
		j checa_loop # Verifica se ja existe linha nos pixels adjacentes
		voltaTres:
			sne $t9, $t2, 1
			bne $t2, 1, setup
			addi pos_atual, pos_atual, -64 # Subtrai 64 bits para ir para o quadrado acima
			sw vermelho, (pos_atual)
			
			#Atualiza pilhas
			addi pilha1, pos_atual, 1024
			sw $s4, (pilha1) #armazena indice na pilha1
			sw pos_atual, (pilha2) #armazena posicao na pilha2
			addi pilha2, pilha2, 4
			
			j end
	end:
		jr $ra # Retorna para a linha seguinte a que a funcao foi chamada

checa_loop:
	li $t1, 0 # posicao para verificacao 
	li $t2, 0 # contador de numero de vizinhos
	
	bne $t6, 1, ok
	bne $t7, 1, ok
	bne $t8, 1, ok
	bne $t9, 1, ok
	add $s4, $zero, 30
	j end

	ok:
	
	beq $t0, 0, Zero # Esquerda
	beq $t0, 1, Um   # Direita
	beq $t0, 2, Dois # Baixo
	beq $t0, 3, Tres # Cima
	
	Zero:
		addi $t3, pos_atual, -4 # vai para a posicao gerada
		lw $t4, ($t3)
		beq $t4, vermelho, retorno # verifica se a posicao ja esa pintada
		j limites
	Um:
		addi $t3, pos_atual, 4 # vai para a posicao gerada
		lw $t4, ($t3)
		beq $t4, vermelho, retorno # verifica se a posicao ja esa pintada
		j limites
	Dois:
		addi $t3, pos_atual, 64 # vai para a posicao gerada
		lw $t4, ($t3)
		beq $t4, vermelho, retorno # verifica se a posicao ja esa pintada
		j limites
	Tres:
		addi $t3, pos_atual, -64 # vai para a posicao gerada
		lw $t4, ($t3)
		beq $t4, vermelho, retorno # verifica se a posicao ja esa pintada
		
	limites:
		sgt $t5, $t3, 0x100403FC # Limite Inferior do mapa
		beq $t5, 1, retorno
	
		slt $t5, $t3, pos_inicial # Limite Superior do mapa
		beq $t5, 1, retorno
		
		beq $t0, 0, limites_esquerda # se a proxima posicao for a esquerda, verifica os limites na esquerda
		beq $t0, 1, limites_direita # se a proxima posicao for a direita, verifica os limites na direita
		j cima
		
		# verifica se a posicao atual eh uma das bordas da direita
		limites_direita:
			beq pos_atual, 0x1004003C, retorno
			beq pos_atual, 0x1004007C, retorno
			beq pos_atual, 0x100400BC, retorno
			beq pos_atual, 0x100400FC, retorno
			beq pos_atual, 0x1004013C, retorno
			beq pos_atual, 0x1004017C, retorno
			beq pos_atual, 0x100401BC, retorno
			beq pos_atual, 0x100401FC, retorno
			beq pos_atual, 0x1004023C, retorno
			beq pos_atual, 0x1004027C, retorno
			beq pos_atual, 0x100402BC, retorno
			beq pos_atual, 0x100402FC, retorno
			beq pos_atual, 0x1004033C, retorno
			beq pos_atual, 0x1004037C, retorno
			beq pos_atual, 0x100403BC, retorno
			beq pos_atual, 0x100403FC, retorno
			j cima
			
		# verifica se a posicao atual eh uma das bordas da esquerda
		limites_esquerda:
			beq pos_atual, 0x10040000, retorno
			beq pos_atual, 0x10040040, retorno
			beq pos_atual, 0x10040080, retorno
			beq pos_atual, 0x100400C0, retorno
			beq pos_atual, 0x10040100, retorno
			beq pos_atual, 0x10040140, retorno
			beq pos_atual, 0x10040180, retorno
			beq pos_atual, 0x100401C0, retorno
			beq pos_atual, 0x10040200, retorno
			beq pos_atual, 0x10040240, retorno
			beq pos_atual, 0x10040280, retorno
			beq pos_atual, 0x100402C0, retorno
			beq pos_atual, 0x10040300, retorno
			beq pos_atual, 0x10040340, retorno
			beq pos_atual, 0x10040380, retorno
			beq pos_atual, 0x100403C0, retorno
	
	# verifica se ja existe linha acima da proxima posicao
	cima:
		addi $t1, $t3, -64
		lw $t5, ($t1) # carrega o valor contido na posicao de memoria
		bne $t5, vermelho, baixo
		addi $t2, $t2, 1 # incrementa 1 no numero de vizinhos
		
	# verifica se ja existe linha abaixo da proxima posicao
	baixo:
		li $t1, 0
		addi $t1, $t3, 64
		lw $t5, ($t1) # carrega o valor contido na posicao de memoria
		bne $t5, vermelho, esquerda
		addi $t2, $t2, 1 # incrementa 1 no numero de vizinhos
		
	# verifica se ja existe linha a esquerda da proxima posicao
	esquerda:
		li $t1, 0
		addi $t1, $t3, -4
		lw $t5, ($t1) # carrega o valor contido na posicao de memoria
		bne $t5, vermelho, direita
		addi $t2, $t2, 1 # incrementa 1 no numero de vizinhos
		
	# verifica se ja existe linha a direita da proxima posicao
	direita:
		li $t1, 0
		addi $t1, $t3, 4
		lw $t5, ($t1) # carrega o valor contido na posicao de memoria
		bne $t5, vermelho, retorno
		addi $t2, $t2, 1 # incrementa 1 no numero de vizinhos
	
	# retorna para a funcao labirinto
	retorno:
		beq $t0, 0, voltaZero # Esquerda
		beq $t0, 1, voltaUm   # Direita
		beq $t0, 2, voltaDois # Baixo
		beq $t0, 3, voltaTres # Cima

procura:
	li $s5, 0x000000	# Cor Preta
	li $t2, 0
	addi $s4, $s1, 1023	# Ultima pos do mapa
	
	
	veCol:			# Verifica se tem labirinto na coluna
	move $t0, $s0		# Posicao a ser verificada
		# Ve coluna acima
		veCima:
			addi $t0, $t0, -64	# Pos acima
			lw $t3, ($t0)		# Cor da pos
			# Condicoes de busca
			blt $t0, $s1, veBaixo	# Se esta na ultima posicao da coluna (Break)
			bne $t3, $s2, veCima	# Se n�o achar labirinto (Continua)
			j andaCima		# Achou labirinto
			
		# Ve coluna abaixo
		veBaixo:
			addi $t0, $t0, 64	# Pos abaixo
			lw $t3, ($t0)		# Cor da pos
			# Condicoes de busca
			bgt $t0, $s4, veLinha	# Se esta na ultima pos da coluna (Break)
			bne $t3, $s2, veBaixo	# Se nao achar labirinto (Continua)
			j andaBaixo		# Achou labirinto
	
	veLinha:
		beq $t2, 0, proxLinha
		beq $t2, 1, voltaLinha
		proxLinha:
			# Delay
			li $v0, 32
			li $a0, 500
			syscall
			
			# Calculando mod
			sub $t4, $s0, $s1	# indice da pos
			addi $t4, $t4, 4	# Ajuste
			div $t1, $t4, 64	# quociente
			mul $t1, $t1, 64	# multiplica
			sub $t1, $t4, $t1	# mod

			
			# Se estiver na borda
			beqz $t1, voltaLinha
			
			# Se nao for borda
			
			# Anda pra direita
			sw $s5, ($s0)		# Pinta de preto
			addi $s0, $s0, 4	# Prox pos
			lw $t3, ($s0)		# Carrega cor da prox pos
			sw $s3, ($s0)		# Pinta robo
			
			# Achou labirinto
			beq $t3, $s2, Saida
			
			# Nao achou labirinto
			j veCol
					
		voltaLinha:
			# Delay
			li $v0, 32
			li $a0, 500
			syscall
			addi $t2, $zero, 1
		 	
		 	# Anda para esquerda
		 	sw $s5, ($s0)		# Pinta de preto
		 	addi $s0, $s0, -4	# Prox pos
		 	lw $t3, ($s0)		# Carrega cor da prox pos
			sw $s3, ($s0)		# Pinta robo
			
			# Achou labirinto
		 	beq $t3, $s2, Saida
		 	
		 	# Nao achou labirinto
		 	j veCol
		 	
		 # Anda para cima ate achar labirinto	
		 andaCima:
		 	move $t0, $s0
		 	# Delay
			li $v0, 32
			li $a0, 500
			syscall
			
			# Anda para cima
			sw $s5, ($s0)		# Pinta de preto
		 	addi $s0, $s0, -64	# Prox pos
		 	lw $t3, ($s0)		# Carrega cor da prox pos
		 	sw $s3, ($s0)		# Pinta robo
		 	
		 	#Achou labirinto
		 	beq $t3, $s2, Saida
		 	j andaCima
		 
		 # Anda para baixo ate achar labirinto
		 andaBaixo:
			move $t0, $s0
			# Delay
			li $v0, 32
			li $a0, 500
			syscall
			
			# Anda para baixo
			sw $s5, ($s0)		# Pinta de preto
		 	addi $s0, $s0, 64	# Prox pos
		 	lw $t3, ($s0)		# Carrega cor da prox pos
		 	sw $s3, ($s0)		# Pinta robo
		 	
		 	# Achou labirinto
		 	beq $t3, $s2, Saida
		 	j andaBaixo
		 	
		 Saida:
jr $ra

pintaRobo:
	#Procura posicao vazia
	posicao:	
		# Gera numero aleatorio de 0 a 255 e salva em pos_atual
		li $v0, 42 
		li $a1, 256
		syscall
		move $t2, $a0
		
		# Atualiza posicao inicial de t0
		move $t0, $t1
			
		# Multiplica o numero por 4 (bits)
		add $t2, $t2, $t2
		add $t2, $t2, $t2
		add pos_atual, $t2, pos_inicial
		
		# Carrega valor da posicao
		lw $t3, (pos_atual)
		beq $t3, vermelho, posicao	
	
	sw azul, (pos_atual) # Pinta robo no mapa

	jr $ra

percorre:
	move $s4, $ra
	
	# Tamanho do labirinto x4
	addi $t4, $s1, 1024 	# Pos inicial pilha1
	addi $t4, $t4, 1028	# Pos inicial pilha2
	sub  $t4, pilha2, $t4	
	
	addi pilha2, pos_inicial, 2048	#Pos atual da pilha2
	add $t0, pilha2, $t4		#Pos final da pilha2
	move $t1, pos_atual
	addi $t1, $t1, 1024		#Pos atual da Pilha1

	#Calcula posicao da Pilha1
	lw $t2, ($t1)			#Recupera o indice (dado da pilha1)
	add $t2, $t2, $t2
	add $t2, $t2, $t2
	
	#Calcula posicao do Robo pela pilha 2
	add pilha2, $t2, pilha2

	# Se estiver na ultima pos s� faz camin de volta
	beq pilha2, $t0, caminVolta
	# Anda primeira metade
	addi $t3, $zero, 4
	jal andaRobo
	
	caminVolta:
	# Anda caminho de volta
	addi $t3, $zero, -4
	sub $t0, $t0, $t4
	jal andaRobo
	
	
	move $ra, $s4
	jr $ra
	
# Robo anda quando encontra o labirinto
andaRobo:

	# Calcula proxima posicao
	add pilha2, pilha2, $t3
	
	# Delay
	li $v0, 32
	li $a0, 500
	syscall
	
	# Anda
	lw $t2,(pilha2)			# Recupera posicao na pilha2
	sw azul, ($t2)			# pinta robo
	sw vermelho, (pos_atual)	# pinta o mapa
	move pos_atual, $t2		# atualiza pos atual
	bne pilha2, $t0, andaRobo	# Verifica se terminou caminho
	jr $ra
	


	

	
