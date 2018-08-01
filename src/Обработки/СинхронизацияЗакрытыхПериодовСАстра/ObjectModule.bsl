﻿#Область ОписаниеОбработки

Функция СведенияОВнешнейОбработке() Экспорт

	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке("2.2.2.1");
	
	// HKEY_LOCAL_MACHINE\SOFTWARE\Classes\ADODB.Connection
	Разрешение = РаботаВБезопасномРежиме.РазрешениеНаСозданиеCOMКласса("ADODB.Connection", "{00000514-0000-0010-8000-00AA006D2EA4}");
	ПараметрыРегистрации.Разрешения.Добавить(Разрешение);
	
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	ПараметрыРегистрации.Версия = Метаданные().Комментарий;
	ПараметрыРегистрации.БезопасныйРежим = Истина;
	ПараметрыРегистрации.Информация = "Синхронизация закрытых периодов с Астра";
	
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление = Метаданные().Представление() + " - Открыть форму";
	НоваяКоманда.Идентификатор = Метаданные().Имя + "Форма";
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	НоваяКоманда.ПоказыватьОповещение = Ложь;
	
	// Для запуска задания по каждой базе по отдельному расписанию
	МассивБаз = ПолучитьМассивБаз();
	Счетчик   = 0 ;
	Для каждого База из МассивБаз Цикл
		
		Счетчик = Счетчик + 1;
		
		НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
		НоваяКоманда.Представление = "Загрузить закрытые периоды (" + База + ")";
		НоваяКоманда.Идентификатор = "ЗагрузитьЗакрытыеПериоды" + Счетчик;
		НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыВызовСерверногоМетода();
		НоваяКоманда.ПоказыватьОповещение = Ложь;
		
	КонецЦикла;

	Возврат ПараметрыРегистрации;

КонецФункции

Процедура ВыполнитьКоманду(ИдентификаторКоманды, ПараметрыКоманды = Неопределено) Экспорт 
	
	НомерБазы = Число(Прав(ИдентификаторКоманды, 1));
	
	Параметры = Новый Структура;
	Параметры.Вставить("База", ПолучитьБазу(НомерБазы));
	Параметры.Вставить("ВыводитьСообщения", Ложь);
	
	ЗаписьЖурналаРегистрации("Синхронизация закрытых периодов с Астра",
		УровеньЖурналаРегистрации.Информация, , , "Номер: " + НомерБазы +", база: " + Строка(Параметры.База));
	
	ЗагрузитьЗакрытыеПериоды(Параметры);
		
КонецПроцедуры	

#КонецОбласти

Функция ПолучитьМассивБаз()
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("ТипБД", "Astra");
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Спр.Наименование КАК Наименование
	|ИЗ
	|	Справочник.ВнешниеИнформационныеБазы КАК Спр
	|ГДЕ
	|	Спр.ТипБД.Наименование = &ТипБД
	|
	|УПОРЯДОЧИТЬ ПО
	|	Наименование";
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Наименование");
	
КонецФункции

Функция ПолучитьБазу(НомерБазы)
	
	Если ЗначениеЗаполнено(НомерБазы) Тогда
		МассивБаз = ПолучитьМассивБаз();
		База = Справочники.ВнешниеИнформационныеБазы.НайтиПоНаименованию(МассивБаз[НомерБазы - 1]);
	Иначе
		База = Неопределено;
	КонецЕсли;	
	
	Возврат База;
	
КонецФункции	

Процедура ЗагрузитьЗакрытыеПериоды(Параметры, АдресРезультата = Неопределено) Экспорт
	
	База = Параметры.База;
	СтрокаСоединения = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(База, "СтрокаПодключения");
	
	Соединение = Новый COMОбъект("ADODB.Connection");
	Соединение.Open(СтрокаСоединения);
	
	ТекстЗапроса =
	"SELECT
	|	CAST(Center_ID AS VARCHAR(36)) as Center_ID,
	|	CenterName,
	|	PeriodEndDate
	|FROM
	|	[uho].[VW_ClosePeriodLastDate]";
	
	Таблица = АСЦ_ОбщийМодуль.ВыполнитьЗапросADO(Соединение, ТекстЗапроса);
	Для каждого СтрокаТЗ из Таблица Цикл
		
		Запись = РегистрыСведений.ДатыЗапретаИзменения.СоздатьМенеджерЗаписи();
		Запись.ДатаЗапрета  = СтрокаТЗ.PeriodEndDate;
		Запись.Пользователь = Перечисления.ВидыНазначенияДатЗапрета.ДляВсехПользователей;
		Запись.Раздел       = ПланыВидовХарактеристик.РазделыДатЗапретаИзменения.НайтиПоНаименованию("Учет по МСФО");
		Запись.Объект       = Справочники.Организации.ПолучитьСсылку(Новый УникальныйИдентификатор(СтрокаТЗ.Center_ID));
		
		Запись.Записать();
		
		Если Параметры.ВыводитьСообщения Тогда
			Сообщить(СтрокаТЗ.CenterName + " " + СтрокаТЗ.PeriodEndDate);
		КонецЕсли;	
		
	КонецЦикла;	
	
	Попытка
		Соединение.Close();
	Исключение
	КонецПопытки;	
	
	УстановитьОбщуюДатуЗапрета();
	
КонецПроцедуры

Процедура УстановитьОбщуюДатуЗапрета()
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Раздел",       ПланыВидовХарактеристик.РазделыДатЗапретаИзменения.НайтиПоНаименованию("Учет по МСФО"));
	Запрос.Параметры.Вставить("Пользователь", Перечисления.ВидыНазначенияДатЗапрета.ДляВсехПользователей);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	МАКСИМУМ(Рег.ДатаЗапрета) КАК ДатаЗапрета
	|ИЗ
	|	РегистрСведений.ДатыЗапретаИзменения КАК Рег
	|ГДЕ
	|	Рег.Раздел = &Раздел
	|	И Рег.Пользователь = &Пользователь";
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		 Возврат;
	КонецЕсли; 
	
	Запись = РегистрыСведений.ДатыЗапретаИзменения.СоздатьМенеджерЗаписи();
	Запись.ДатаЗапрета  = Результат.Выгрузить()[0][0];
	Запись.Пользователь = Перечисления.ВидыНазначенияДатЗапрета.ДляВсехПользователей;
	Запись.Раздел       = ПланыВидовХарактеристик.РазделыДатЗапретаИзменения.НайтиПоНаименованию("Учет по МСФО");
	Запись.Объект       = Запись.Раздел;
	
	Запись.Записать();
		
КонецПроцедуры	
