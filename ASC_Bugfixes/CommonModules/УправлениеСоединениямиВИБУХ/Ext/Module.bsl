﻿
Функция АСЦ_ВернутьТипЗначенияВВидеСтроки(КодТипа,bSQL=0) Экспорт
	
	Если КодТипа = 20 Тогда
		Возврат "Число";
	ИначеЕсли КодТипа = 128 Тогда //"adBinary"
		Возврат "НеПоддерживается";
	ИначеЕсли КодТипа = 11 Тогда //"adBoolean"
		Возврат "Булево";
	ИначеЕсли КодТипа = 8 Тогда //"adBSTR"
		Возврат "Строка";
	ИначеЕсли КодТипа = 136 Тогда //"adChapter"
		Возврат "НеПоддерживается";
	ИначеЕсли КодТипа = 129 Тогда //adChar
		Возврат "Строка";
	ИначеЕсли КодТипа = 6 Тогда //"adCurrency"
		Возврат "Число";
	ИначеЕсли КодТипа = 7 Тогда //"adDate"
		Возврат "Дата";
	ИначеЕсли КодТипа = 133 Тогда //"adDBDate"
		Возврат "Дата";
	ИначеЕсли КодТипа = 134 Тогда //"adDBTime"
		Возврат "Дата";
	ИначеЕсли КодТипа = 135 Тогда //"adDBTimeStamp"
		Возврат "Дата";
	ИначеЕсли КодТипа = 14 Тогда //"adDecimal"
		Возврат "Число";
	ИначеЕсли КодТипа = 5 Тогда //"adDouble"
		Возврат "Число";
	ИначеЕсли КодТипа = 0 Тогда //"adEmpty"
		Возврат "НеПоддерживается";
	ИначеЕсли КодТипа = 10 Тогда //"adError"
		Возврат "НеПоддерживается";
	ИначеЕсли КодТипа = 64 Тогда //"adFileTime"
		Возврат "НеПоддерживается";
	ИначеЕсли КодТипа = 72 Тогда //"adGUID"
		Возврат "НеПоддерживается";
	ИначеЕсли КодТипа = 9 Тогда //"adIDispatch"
		Возврат "НеПоддерживается";
	ИначеЕсли КодТипа = 3 Тогда //"adInteger"
		Возврат "Число";
	ИначеЕсли КодТипа = 13 Тогда //"adIUnknown"
		Возврат "НеПоддерживается";
	ИначеЕсли КодТипа = 205 Тогда //"adLongVarBinary"
		Возврат "НеПоддерживается";
	ИначеЕсли КодТипа = 201 Тогда //"adLongVarChar"
		Возврат "Строка";
	ИначеЕсли КодТипа = 203 Тогда //"adLongVarWChar"
		Возврат "Строка";
	ИначеЕсли КодТипа = 131 Тогда //"adNumeric"
		Возврат "Число";
	ИначеЕсли КодТипа = 138 Тогда //"adPropVariant"
		Возврат "НеПоддерживается";
	ИначеЕсли КодТипа = 4 Тогда //"adSingle"
		Возврат "Число";
	ИначеЕсли КодТипа = 2 Тогда //"adSmallInt"
		Возврат "Число";
	ИначеЕсли КодТипа = 16 Тогда //"adTinyInt"
		Возврат "Число";
	ИначеЕсли КодТипа = 21 Тогда //"adUnsignedBigInt"
		Возврат "Число";
	ИначеЕсли КодТипа = 19 Тогда //"adUnsignedInt"
		Возврат "Число";
	ИначеЕсли КодТипа = 18 Тогда //"adUnsignedSmallInt"
		Возврат "Число";
	ИначеЕсли КодТипа = 17 Тогда //"adUnsignedTinyInt"
		Возврат "Число";
	ИначеЕсли КодТипа = 132 Тогда //"adUserDefined"
		Возврат "НеПоддерживается";
	ИначеЕсли КодТипа = 204 Тогда //"adVarBinary"
		Возврат "НеПоддерживается";
	ИначеЕсли КодТипа = 200 Тогда //"adVarChar"
		Возврат "Строка";
	ИначеЕсли КодТипа = 12 Тогда //"adVariant"
		Возврат "НеПоддерживается";
	ИначеЕсли КодТипа = 139 Тогда //"adVarNumeric"
		Возврат "Число";
	ИначеЕсли КодТипа = 202 Тогда //"adVarWChar"
		//+++Хижинков А.В. 30.01.2017 неверная обработка даты. Исправлено(
		Если bSQL=2 Тогда   //MSSQL
			Возврат "Дата"; 
		Иначе
			Возврат "Строка";
		КонецЕсли;
	ИначеЕсли КодТипа = -1 И bSQL>0 Тогда //"adVarWChar"
			Возврат "Число";
		//+++)Хижинков А.В. 30.01.2017 неверная обработка даты. Исправлено		
	ИначеЕсли КодТипа = 130 Тогда //"adWChar"
		Возврат "Строка";
	Иначе
		Возврат "НеПоддерживается";
	КонецЕсли;
	
КонецФункции

&Вместо("ВернутьКолонкиТаблицы")
Функция АСЦ_ВернутьКолонкиТаблицы(ИмяТаблицы, СтрокаПодключения, ТипКакОписаниеТипов = Истина) Экспорт
	
	ТаблицаКолонок = Новый ТаблицаЗначений;
	ТаблицаКолонок.Колонки.Добавить("Имя");
	ТаблицаКолонок.Колонки.Добавить("ВнутреннееПредставление");
	ТаблицаКолонок.Колонки.Добавить("ОписаниеТипов");
	//+++Хижинков А.В. 30.01.2017 обработка SQL базы(
	Если СтрНайти(СтрокаПодключения,"SQLOLEDB")>0  Тогда
		ЭтоSQL = 2;
	ИначеЕсли   СтрНайти(СтрокаПодключения,"Oracle")>0 Тогда
		ЭтоSQL = 1;
	Иначе
		ЭтоSQL = 0;
	КонецЕсли;
	//)+++Хижинков А.В. 30.01.2017 обработка SQL базы	

	Попытка
		мКаталог                  = Новый COMОбъект("ADOX.Catalog");
		мКаталог.ActiveConnection = СтрокаПодключения;
		ТекущаяТаблица = мКаталог.Tables(ИмяТаблицы);
		Для Каждого Колонка Из ТекущаяТаблица.Columns Цикл
			
			НоваяСтрока = ТаблицаКолонок.Добавить();
			НоваяСтрока.Имя = Колонка.Name;
			НоваяСтрока.ВнутреннееПредставление = ОбщегоНазначенияУХ.ВернутьАлфавитноЦифровоеПредставление(Колонка.Name);
			Если ТипКакОписаниеТипов Тогда
				НоваяСтрока.ОписаниеТипов = ВернутьНаименованиеТипа(Колонка.Type, Колонка.DefinedSize, Колонка.Precision, Колонка.NumericScale);
			Иначе
				НоваяСтрока.ОписаниеТипов = АСЦ_ВернутьТипЗначенияВВидеСтроки(Колонка.Type,ЭтоSQL);
			КонецЕсли;
			
		КонецЦикла;
	Исключение
		
		ОбщегоНазначенияУХ.СообщитьОбОшибке("Ошибка ADO: " + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		
	КонецПопытки;
	мКаталог = Неопределено;
	Возврат ТаблицаКолонок;
	
КонецФункции

&Вместо("ПолучитьДанныеИзТаблицы")
Функция АСЦ_ПолучитьДанныеИзТаблицы(ВИБ, Таблица) Экспорт
	
	ТаблицаДанных = Новый ТаблицаЗначений;
	СоответствиеКолонок = Новый Соответствие;
	
	СтрокаСоединения=ПолучитьСтрокуСоединенияADO(ВИБ,,Таблица.ИмяФайла);
	//+++Хижинков А.В.(
	ЭтоSQL = СтрНайти(СтрокаСоединения,"SQLOLEDB")>0 ИЛИ  СтрНайти(СтрокаСоединения,"Oracle")>0;
	//)+++Хижинков А.В.
	ОбработаноКолонок=0;
	
	Для Каждого РеквизитТаблицы Из Таблица.Реквизиты Цикл
		
		ТипКолонки = ОбщегоНазначенияУХ.ПреобразоватьТипИзСтроки(РеквизитТаблицы.ТипЗначения, Истина);
		СоответствиеКолонок.Вставить(РеквизитТаблицы.Имя, РеквизитТаблицы.ВнутреннееПредставление);
		
		Если ТипКолонки <> Неопределено Тогда
			МассивТипов = Новый Массив;
			МассивТипов.Добавить(ТипКолонки);
			ТаблицаДанных.Колонки.Добавить(РеквизитТаблицы.ВнутреннееПредставление, Новый ОписаниеТипов(МассивТипов));
		Иначе
			ТаблицаДанных.Колонки.Добавить(РеквизитТаблицы.ВнутреннееПредставление);
		КонецЕсли;
		
		ОбработаноКолонок=ОбработаноКолонок+1;
				
	КонецЦикла;
	
	Попытка
		мНаборЗаписей = Новый COMОбъект("ADODB.Recordset");
		//+++ Хижинков А.В. 8.11.2017 было 	мНаборЗаписей.Open("[" + Таблица.Имя + "]", СтрокаСоединения, , , 2);(
		Если ЭтоSQL Тогда
			мНаборЗаписей.Open("select * from " + Таблица.Имя , СтрокаСоединения);    //from UNICUSWEB_RELEASE.
		Иначе
			мНаборЗаписей.Open("[" + Таблица.Имя + "]", СтрокаСоединения, , , 2);
		КонецЕсли;
		//+++ ) Хижинков А.В. 8.11.2017 было 	мНаборЗаписей.Open("[" + Таблица.Имя + "]", СтрокаСоединения, , , 2);(
	Исключение
		ОбщегоНазначенияУХ.СообщитьОбОшибке("Ошибка ADO: " + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Возврат ТаблицаДанных;
	КонецПопытки;
	
	х=1;
	
	Попытка
		
		Если НЕ мНаборЗаписей.EOF И НЕ мНаборЗаписей.EOF Тогда		
		
			мНаборЗаписей.MoveFirst();
			
			
			Пока НЕ мНаборЗаписей.EOF Цикл
				
				НоваяЗапись = ТаблицаДанных.Добавить();
				Для Каждого КлючИЗначение Из СоответствиеКолонок Цикл
					НоваяЗапись[?(ЗначениеЗаполнено(КлючИЗначение.Значение),КлючИЗначение.Значение,КлючИЗначение.Ключ)] = мНаборЗаписей.Fields(КлючИЗначение.Ключ).Value;  ///+++Хижинков А.В. 8.11.2017 было  НоваяЗапись[КлючИЗначение.Значение]
				КонецЦикла;
				
				х=х+1;
				
				мНаборЗаписей.MoveNext();
			КонецЦикла;
			
		КонецЕсли;
		
	Исключение
		ОбщегоНазначенияУХ.СообщитьОбОшибке("Ошибка ADO: " + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	мНаборЗаписей.Close();
	Возврат ТаблицаДанных;
	
КонецФункции

&Вместо("ПолучитьСтруктуруADO")
Функция АСЦ_ПолучитьСтруктуруADO(СтрокаПодключения) Экспорт
	
	ПРОТОКОЛИРУЕМОЕ_СОБЫТИЕ = "ОбщийМодуль.УправлениеСоединениямиВИБУХ.ПолучитьСтруктуруADO";
	
	Таблицы = Новый ТаблицаЗначений;
	Таблицы.Колонки.Добавить("Имя");
	Таблицы.Колонки.Добавить("Колонки");
	Таблицы.Колонки.Добавить("Связи");
	//+++Хижинков А.В. 30.01.2017 обработка SQL базы(
	Если СтрНайти(СтрокаПодключения,"SQLOLEDB")>0  Тогда
		ЭтоSQL = 2;
	ИначеЕсли   СтрНайти(СтрокаПодключения,"Oracle")>0 Тогда
		ЭтоSQL = 1;
	Иначе
		ЭтоSQL = 0;
	КонецЕсли;
	//)+++Хижинков А.В. 30.01.2017 обработка SQL базы	

	
	Попытка
		
		ADOX_Catalog                  = Новый COMОбъект("ADOX.Catalog");
		ADOX_Catalog.ActiveConnection = СтрокаПодключения;
		
		Для Каждого Table Из ADOX_Catalog.Tables Цикл
			
			Если НЕ (Найти(ВРЕГ(Table.Type), "TABLE") > 0 ИЛИ ВРЕГ(Table.Type) = "VIEW") Тогда
				Продолжить;
			КонецЕсли;
			
			Таблица = Таблицы.Добавить();
			Таблица.Имя = Table.Name;
			
			Колонки = Новый ТаблицаЗначений;
			Колонки.Колонки.Добавить("Имя");
			Колонки.Колонки.Добавить("ВнутреннееПредставление");
			Колонки.Колонки.Добавить("ОписаниеТипов");
			
			Для Каждого Column Из Table.Columns Цикл
				
				Колонка = Колонки.Добавить();
				Колонка.Имя = Column.Name;
				Колонка.ВнутреннееПредставление = ОбщегоНазначенияУХ.ВернутьАлфавитноЦифровоеПредставление(Column.Name);
				Колонка.ОписаниеТипов = АСЦ_ВернутьТипЗначенияВВидеСтроки(Column.Type,ЭтоSQL);//+++Хижинков А.В. добавил АСЦ_ВернутьТипЗначенияВВидеСтроки(Column.Type,ЭтоSQL)
				
			КонецЦикла; 
			
			Таблица.Колонки = Колонки;
			
			Связи = Новый ТаблицаЗначений;
			Связи.Колонки.Добавить("СвязаннаяТаблица");
			Связи.Колонки.Добавить("КолонкаТекущейТаблицы");
			Связи.Колонки.Добавить("КолонкаСвязаннойТаблицы");
			
			Для Каждого Ключ Из Table.Keys Цикл
				
				Если НЕ Ключ.Type = 2 Тогда // Ключ не является FOREIGN KEY.
					Продолжить;
				КонецЕсли;
				
				Для Каждого Column Из Ключ.Columns Цикл
					Связь = Связи.Добавить();
					Связь.СвязаннаяТаблица = Ключ.RelatedTable;
					Связь.КолонкаТекущейТаблицы = Column.Name;
					Связь.КолонкаСвязаннойТаблицы = Column.RelatedColumn;
				КонецЦикла;
				
			КонецЦикла;
			
			Таблица.Связи = Связи;
			
		КонецЦикла;
		
		ADOX_Catalog.ActiveConnection.Close();
		
	Исключение
		ПротоколируемыеСобытияУХ.ДобавитьЗаписьПредупреждение(ПРОТОКОЛИРУЕМОЕ_СОБЫТИЕ,,, "Системная ошибка. Подробности в полном протоколе.", ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Таблицы.Очистить();
	КонецПопытки;
		
	Возврат Таблицы;
	
КонецФункции
	
