﻿
&Вместо("HTTPСоединениеСервисаСклонений")
Функция АСЦ1_HTTPСоединениеСервисаСклонений()
	
	//АСЦ Ситников++
	//АдресСервера = "ws3.morpher.ru";
	АдресСервера = "http://ws3.morpher.ru";
	//АСЦ Ситников--	
	
	ИнтернетПрокси = Неопределено;
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПолучениеФайловИзИнтернета") Тогда
		МодульПолучениеФайловИзИнтернетаКлиентСервер = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернетаКлиентСервер");
		ИнтернетПрокси = МодульПолучениеФайловИзИнтернетаКлиентСервер.ПолучитьПрокси(АдресСервера);
	КонецЕсли;
	
	Таймаут = 10;
	
	ЗащищенноеСоединение = Новый ЗащищенноеСоединениеOpenSSL(, Новый СертификатыУдостоверяющихЦентровОС);
	Возврат Новый HTTPСоединение(АдресСервера,,,, ИнтернетПрокси, Таймаут, ЗащищенноеСоединение);
	
КонецФункции
