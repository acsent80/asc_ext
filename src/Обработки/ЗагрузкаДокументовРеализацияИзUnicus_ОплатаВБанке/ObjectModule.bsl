﻿#Область ОписаниеОбработки

Функция СведенияОВнешнейОбработке() Экспорт
	
	//ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке("2.1.3.1");
	//ПараметрыРегистрации.БезопасныйРежим = Ложь;
	
	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке("2.2.2.1");
	
	// HKEY_LOCAL_MACHINE\SOFTWARE\Classes\ADODB.Connection
	Разрешение = РаботаВБезопасномРежиме.РазрешениеНаСозданиеCOMКласса("ADODB.Connection", "{00000514-0000-0010-8000-00AA006D2EA4}");
	ПараметрыРегистрации.Разрешения.Добавить(Разрешение);
	
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	ПараметрыРегистрации.Версия = Метаданные().Комментарий;
	ПараметрыРегистрации.Информация = "Загрузка документов Реализация из UNICUS";
	
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление = Метаданные().Представление() + " - Открыть форму";
	НоваяКоманда.Идентификатор = Метаданные().Имя + "Форма";
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	НоваяКоманда.ПоказыватьОповещение = Ложь;
	
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление = "Загрузить реализации";
	НоваяКоманда.Идентификатор = "ЗагрузитьРеализации";
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыВызовСерверногоМетода();
	НоваяКоманда.ПоказыватьОповещение = Ложь;
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

Процедура ВыполнитьКоманду(ИдентификаторКоманды, ПараметрыКоманды = Неопределено) Экспорт 
	
	Если АСЦ_Обмены.РаботаСВнешнимиРесурсамиЗаблокирована() Тогда
		Сообщить("Работа с внешними ресурсами заблокирована.
		|Обмен можно проводить только через форму");
		Возврат;
	КонецЕсли;	
	
	Параметры = Новый Структура;
	
	База = ХранилищеОбщихНастроек.Загрузить("ЗагрузкаДокументовИзUnicus", "База",, "ЗагрузкаДокументовИзUnicus");
	Если НЕ ЗначениеЗаполнено(База) Тогда
		База = Справочники.ВнешниеИнформационныеБазы.НайтиПоНаименованию("Юникус");
	КонецЕсли;
	
	Параметры.Вставить("База",        База);
	Параметры.Вставить("ДатаНач",     ТекущаяДата() - 10*86400);
	Параметры.Вставить("ДатаКон",     '2100-01-01');
	Параметры.Вставить("Организация", Неопределено);
	Параметры.Вставить("ПерезаполнятьДокументы",   Ложь);
	Параметры.Вставить("ПерезаполнятьДоговоры",    Ложь);
	Параметры.Вставить("ВыводитьСообщения",        Ложь);
	Параметры.Вставить("ВыводитьСообщения",        Ложь);
	Параметры.Вставить("ОтложенноеПроведение",     Ложь);
	Параметры.Вставить("ЗагружатьДокументыОплаты", Ложь);
	Параметры.Вставить("ВариантЗагрузки",          "ПериодИзменений");
	
	ЗагрузитьРеализации(Параметры);
	
КонецПроцедуры	

#КонецОбласти

Процедура ЗагрузитьРеализации(Параметры, АдресРезультата = Неопределено, Знач ТаблицаДанных = Неопределено) Экспорт
	
	База        = Параметры.База;
	ДатаНач     = Параметры.ДатаНач;
	Если НЕ ЗначениеЗаполнено(ДатаНач) Тогда
		ДатаНач = '2018-01-01';
	КонецЕсли;	
	ДатаКон     = Параметры.ДатаКон;
	
	ДлительныеОперации.СообщитьПрогресс(0, "Получение данных из Unicus");
	
	ТекстЗапроса  = АСЦ_ЗагрузкаUnicus.ПолучитьТекстЗапроса_ОплатаВБанке(ДатаНач, ДатаКон, Параметры);
	ТаблицаДанных = АСЦ_ОбщегоНазначения.ПолучитьТаблицуДанных(Параметры.База, ТекстЗапроса);
	
	АСЦ_ЗагрузкаUnicus.ЗагрузитьДокументы(Параметры, АдресРезультата, ТаблицаДанных);
	
КонецПроцедуры	

