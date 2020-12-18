;Regiszterekben található 16 bites előjel nélküli egész átalakítása 5 db BCD kódú számmá.
;Az eredményt 3 regiszterben kapjuk vissza: az elsőben a 4 felső bit 0, alatta a legmagasabb helyiértékű digit,
;a másodikban a következő két digit,
;a harmadikban a legkisebb helyiértékű két digit.
;Bemenet: az átalakítandó számérték 2 regiszterben
;Kimenet: az átalakított szám 3 regiszterben.

$nomod51
$include (SI_EFM8BB3_Defs.inc)

;Ugrótábla
cseg at 0 ; Main címkére ugrás a 0-s címen
sjmp Main

;Bemenetek: INPUT_LOW és INPUT_HIGH
;Inicializációk elvégzése, a bemenet betöltése R1 és R2 regiszterekbe, a feladatot megvalósító szubrutin meghívása majd várakozás
Main:	clr IE_EA ;minden interrupt kikapcsolása
		mov WDTCN, #0DEh ;watchdog timer kikapcsolása
		mov WDTCN, #0ADh
		setb IE_EA
		mov R1, #012h ;bemenet alsó 8 bitje
		mov R2, #012h ;bemenet felső 8 bitje
		call Shift ;hívjuk a szubrutint
		jmp $ ;visszatérés után várakozunk

;Bemenetek: nincs (semmit nem használok belül, amit nem én definiáltam)
;Kimenetek: R0 (ShiftLoop szubrutin számára átadjuk neki az értékét, mert ő használni fogja)
;A Shift szubrutin állítja be a kimenetek értékeit és hívja meg a feladatot megoldó algoritmust
Shift:	mov R0, #0x10 ;futóváltozó Shift ciklusnak (16 bites bemenet->16x kell lefusson)
		;a BCD számokat tároló regiszterek inicializálása 0-ba az algoritmus működése szerint
		mov R3, #0x00
		mov R4, #0x00
		mov R5, #0x00
		call ShiftLoop
		ret

;A ShiftLoop szubrutin végzi el a Double dabble algoritmust, mely a bintáris számot BCD-vé konvertálja
;Bemenet: R0..5 (mindet használom, pedig nem ebben a szubrutinban kerültek definiálásra)
;Kimenet: R3..5 (a BCD digiteket tartalmazó regiszterek)
;Megváltozott regiszterek: R0..5
ShiftLoop:	clr C ;Carry-flag clear

			mov A, R1 ;input alsó 8 bitjét betöltjük az akkumulátorba, hogy műveletet végezhessünk rajta
			rlc A ;balra shifteljük Carry-flag állítással túlcsordulás esetén
			mov R1, A ;az eltolt érték visszatöltése

			; ugyanazok a lépések az input felső 8 bitjére
			mov A, R2
			rlc A
			mov R2, A

			;BCD digitek shiftelése ADDC-vel, hogy használhassuk a DA A utasítást BCD korrekcióra
			mov A, R3
			addc A, R3
			da A
			mov R3, A

			mov A, R4
			addc A, R4
			da A
			mov R4, A

			mov A, R5
			addc A, R5
			da A
			mov R5, A

			;ha a futóváltozó értéke 0, akkor a szubrutin 16x lefutott, kiléphetünk belőle, R3,4,5 tartalmazza a szükséges kimeneteket
			djnz R0, ShiftLoop
			ret

END
