* programa para deflacionar a Pnad Contínua Trimestral - com mudança de base
* o comando é assim:

* deflatoraB	ÚLTIMO_TRIMESTRE_DISPONÍVEL	ÚLTIMO_ANO_DISPONÍVEL	TRIMESTRE_BASE	ANO_BASE
* exemplo:
* o último trimestre disponível é o do 2T2020 e vc quer deflacionar para valores do 4T2018:
*
*		deflatora 2 2020 4 2018



capture program drop deflatoraB
program define deflatoraB
	
	tempfile pnad
	save `pnad'
	
	clear all
	cd "/mnt/hdexterno/bancos/Bases Não Identificadas/PNAD/PNADC_Trimestral/" 
	
	copy ftp://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Trimestral/Microdados/Documentacao/Deflatores.zip Deflatores.zip
	unzipfile Deflatores.zip, replace
	
	if (`1'==1) {
	import excel using deflator_PNADC_`2'_trimestral_010203.xls, firstrow
	}
	
	else if (`1'==2) {
	import excel using  deflator_PNADC_`2'_trimestral_040506.xls, firstrow
	}
	
	else if (`1'==3) {
	import excel using  deflator_PNADC_`2'_trimestral_070809.xls, firstrow
	}
	
	else if (`1'==4) {
	import excel using  deflator_PNADC_`2'_trimestral_101112.xls, firstrow
	}
	
	gen Trimestre=.
	replace Trimestre=1 if (trim=="01-02-03")
	replace Trimestre=2 if (trim=="04-05-06")
	replace Trimestre=3 if (trim=="07-08-09")
	replace Trimestre=4 if (trim=="10-11-12")
	keep if Trimestre!=.

	cap: rename ano Ano
	cap: rename uf UF
	
	destring Ano, replace
	destring Trimestre, replace
	destring UF, replace
	
	destring Habitual, replace dpcomma
	destring Efetivo, replace dpcomma
	
	***
	
	* salva a base de deflatores
	tempfile def
	save `def'

	* junta com a base da pnad salva
	merge 1:m Ano Trimestre UF using `pnad'
	
	drop trim
	
	drop if _merge==1
	drop _merge
	
	
	* gera variaveis com ano e trimestre base
	gen Trimestrebase=`3'
	gen Anobase=`4'
	
	* salva bco
	save `pnad', replace
	
	* abre base de deflatores
	use `def'
	
	* junta com a pnad, mas de acordo com o ano e o trimestre base
	rename Ano Anobase
	rename Trimestre Trimestrebase
	rename Habitual HabitualB
	rename Efetivo EfetivoB
	
	merge 1:m Anobase Trimestrebase UF using `pnad'
	
	drop trim
	
	drop if _merge==1
	drop _merge
	
	* gera os novos deflatores nas novas bases
	gen Habitual_base_`3'T`4' = Habitual/HabitualB
	gen Efetivo_base_`3'T`4' = Efetivo/EfetivoB
	
	drop HabitualB EfetivoB Anobase Trimestrebase
		
end


/*

DOcumentação:
* ftp://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Anual/Microdados/Visita/Documentacao_Geral/
