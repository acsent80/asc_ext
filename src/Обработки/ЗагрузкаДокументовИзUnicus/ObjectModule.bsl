﻿#Область ОписаниеОбработки

Функция СведенияОВнешнейОбработке() Экспорт

	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке("2.1.3.1");
	
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	ПараметрыРегистрации.Версия = Метаданные().Комментарий;
	ПараметрыРегистрации.БезопасныйРежим = Ложь;
	ПараметрыРегистрации.Информация = "Загрузка документов из UNICUS";
	
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
	
	Параметры = Новый Структура;
	
	База = ХранилищеОбщихНастроек.Загрузить("ЗагрузитьДокументыИзUnicus", "База",, "ЗагрузитьДокументыИзUnicus");
	Если НЕ ЗначениеЗаполнено(База) Тогда
		База = Справочники.ВнешниеИнформационныеБазы.НайтиПоНаименованию("Юникус");
	КонецЕсли;
	
	Параметры.Вставить("База",        База);
	Параметры.Вставить("ДатаКон",     ТекущаяДата());
	Параметры.Вставить("ДатаНач",     НачалоДня(ТекущаяДата() - 86400));
	Параметры.Вставить("Организация", Неопределено);
	Параметры.Вставить("ПерезаполнятьДокументы", Ложь);
	
	//ЗаписьЖурналаРегистрации("Загрузка отчета UNICUS",
	//	УровеньЖурналаРегистрации.Предупреждение,,, "Параметры: " + вСтроку(ПараметрыКоманды));
	
	Если ИдентификаторКоманды = "ЗагрузитьРеализации" Тогда
		ЗагрузитьРеализации(Параметры);
	//ИначеЕсли ИдентификаторКоманды = "ЗагрузитьОтчетUNICUS_Acts" Тогда
	//	ЗагрузитьActs();
	КонецЕсли;	
	
КонецПроцедуры	

#КонецОбласти

#Область СлужебныеФункции

Функция ВыполнитьЗапросADO(Соединение, ТекстЗапроса)
	
	НаборЗаписей = Соединение.Execute(ТекстЗапроса);
	
	ТаблицаДанных = Новый ТаблицаЗначений;
	Для Счетчик = 0 По НаборЗаписей.Fields.Count - 1 Цикл
		ТаблицаДанных.Колонки.Добавить(НаборЗаписей.Fields(Счетчик).Name);
	КонецЦикла;	
	
	Если НЕ НаборЗаписей.EOF Тогда		

		НаборЗаписей.MoveFirst();
		Пока НЕ НаборЗаписей.EOF Цикл
			
			НоваяЗапись = ТаблицаДанных.Добавить();
			Для каждого Колонка из ТаблицаДанных.Колонки Цикл
				НоваяЗапись[Колонка.Имя] = НаборЗаписей.Fields(Колонка.Имя).Value;
			КонецЦикла;	

			НаборЗаписей.MoveNext();
			
		КонецЦикла;
		
	КонецЕсли;
	
	НаборЗаписей.Close();
	
	Возврат ТаблицаДанных;
	
КонецФункции

Процедура ЗаписатьДокумент(ДокОбъект, Сообщать = Истина)
	
	Если ДокОбъект = Неопределено Тогда
		Возврат;
	КонецЕсли;	
	
	Если ДокОбъект.Проведен Тогда
		Режим = РежимЗаписиДокумента.Проведение;
	Иначе
		Режим = РежимЗаписиДокумента.Запись;
	КонецЕсли;	
	
	Попытка
		ДокОбъект.Записать(Режим);
	Исключение
		ОписаниеОшибки = ОписаниеОшибки();
		Сообщить(ОписаниеОшибки);
		ЗаписьЖурналаРегистрации("Загрузка документов UNICUS",
			УровеньЖурналаРегистрации.Ошибка, ДокОбъект.Метаданные(), ДокОбъект.Ссылка, ОписаниеОшибки);
	КонецПопытки;	
	
	Если Сообщать Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = Строка(ДокОбъект);
		Сообщение.КлючДанных = ДокОбъект.Ссылка;
		Сообщение.Сообщить();
	КонецЕсли;
	
КонецПроцедуры	

Функция ЗначенияОтличаются(Структруа1, Структура2)
	
	Для каждого КлючИЗначение Из Структруа1 Цикл
		
		Если КлючИЗначение.Значение <> Структура2[КлючИЗначение.Ключ] Тогда
			Возврат Истина;
		КонецЕсли;
		
	КонецЦикла;	
	
	Возврат Ложь;
	
КонецФункции	

#КонецОбласти

#Область ПоискДанных

Функция ПолучитьОрганизациюПоСоотвествию(Наименование, Настройка, База, Кэш)
	
	СпрСсылка = Кэш[Наименование];
	Если СпрСсылка <> Неопределено Тогда
		Возврат СпрСсылка;
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Наименование", Наименование);
	Запрос.Параметры.Вставить("База",         База);
	Запрос.Параметры.Вставить("Настройка",    Настройка);
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Рег.ОбъектТекущейИБ КАК ОбъектТекущейИБ
	|ИЗ
	|	РегистрСведений.СоответствиеОбъектовТекущейИВнешнихИБ КАК Рег
	|ГДЕ
	|	Рег.ОбъектВнешнейИБ = &Наименование
	|	И Рег.НастройкаСоответствия = &Настройка
	|	И Рег.ИспользуемаяИБ = &База";
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		СпрСсылка = Справочники.Организации.ПустаяСсылка();
	Иначе
		СпрСсылка = Результат.Выгрузить()[0][0];
	КонецЕсли;	
	
	Кэш.Вставить(Наименование, СпрСсылка);
	Возврат СпрСсылка;
	
КонецФункции

Функция ПолучитьОрганизациюПоИНН(ИНН, Кэш)
	
	СпрСсылка = Кэш[ИНН];
	Если СпрСсылка <> Неопределено Тогда
		Возврат СпрСсылка;
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("ИНН", ИНН);
	
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Спр.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Организации КАК Спр
	|ГДЕ
	|	Спр.ИНН = &ИНН";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		СпрСсылка = Результат.Выгрузить()[0][0];
	Иначе
		СпрСсылка = Справочники.Организации.ПустаяСсылка();
	КонецЕсли;	
	
	Кэш.Вставить(ИНН, СпрСсылка);
	Возврат СпрСсылка;
	
КонецФункции	

Функция ПолучитьНоменклатуру(Наименование, Кэш)
	
	СпрСсылка = Кэш[Наименование];
	Если СпрСсылка <> Неопределено Тогда
		Возврат СпрСсылка;
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Наименование", Наименование);
	
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Спр.Ссылка
	|ИЗ
	|	Справочник.Номенклатура КАК Спр
	|ГДЕ
	|	НЕ Спр.ЭтоГруппа
	|	И НЕ Спр.ПометкаУдаления
	|	И Спр.Наименование = &Наименование";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		СпрСсылка = Результат.Выгрузить()[0][0];
	Иначе
		
		СпрОбъект = Справочники.Номенклатура.СоздатьЭлемент();
		СпрОбъект.Наименование =  Наименование;
		СпрОбъект.Записать();
		
		СпрСсылка = СпрОбъект.Ссылка;
		
	КонецЕсли;	
	
	Кэш.Вставить(Наименование, СпрСсылка);
	Возврат СпрСсылка;
	
КонецФункции

Функция ПолучитьКонтрагента(Данные, Параметры, Перезаписывать = Ложь)
	
	СпрСсылка  = Неопределено;
	СтрПаспорт = "";
	
	Если ЗначениеЗаполнено(Данные.КонтрагентИНН) Тогда
		СпрСсылка = АСЦ_ОбщийМодуль.НайтиКонтрагента(Данные.Контрагент, Данные.КонтрагентИНН, Данные.КонтрагентКПП);
		ЮридическоеФизическоеЛицо = Перечисления.ЮридическоеФизическоеЛицо.ЮридическоеЛицо;
		Родитель  = Параметры.КонтрагентРодительЮЛ;
	Иначе
		
		СтрПаспорт = СокрЛП(Данные.КонтрагентПаспортСерия) + " " + СокрЛП(Данные.КонтрагентПаспортНомер); 
		Если ЗначениеЗаполнено(Данные.КонтрагентПаспортДата) Тогда
			СтрПаспорт = СтрПаспорт + " выдан: "  + Формат(Данные.КонтрагентПаспортДата, "ДФ=dd.MM.yyyy");
		КонецЕсли;
		СтрПаспорт = СокрЛП(СтрПаспорт);
		
		ЮридическоеФизическоеЛицо = Перечисления.ЮридическоеФизическоеЛицо.ФизическоеЛицо;
		Родитель   = Параметры.КонтрагентРодительФЛ;
		
		Запрос = Новый Запрос;
		
		Если ЗначениеЗаполнено(СтрПаспорт) Тогда
			
			Запрос.Параметры.Вставить("Паспорт", СтрПаспорт);
			Запрос.Текст =
			"ВЫБРАТЬ
			|	Спр.Ссылка КАК Ссылка
			|ИЗ
			|	Справочник.Контрагенты КАК Спр
			|ГДЕ
			|	НЕ Спр.ПометкаУдаления
			|	И Спр.ДокументУдостоверяющийЛичность = &Паспорт";
			
			Результат = Запрос.Выполнить();
			Если НЕ Результат.Пустой() Тогда
				СпрСсылка = Результат.Выгрузить()[0][0];
			КонецЕсли;
			
		КонецЕсли;
		
		Если СпрСсылка = Неопределено Тогда
			
			Запрос.Параметры.Вставить("Наименование", Данные.Контрагент);
			Запрос.Параметры.Вставить("Родитель",     Родитель);
			
			Запрос.Текст =
			"ВЫБРАТЬ
			|	Спр.Ссылка КАК Ссылка
			|ИЗ
			|	Справочник.Контрагенты КАК Спр
			|ГДЕ
			|	НЕ Спр.ПометкаУдаления
			|	И Спр.Наименование = &Наименование
			|	И Спр.Родитель = &Родитель";
			
			Результат = Запрос.Выполнить();
			Если НЕ Результат.Пустой() Тогда
				СпрСсылка = Результат.Выгрузить()[0][0];
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СпрСсылка) Тогда
		
		Если Перезаписывать Тогда
			СпрОбъект = СпрСсылка.ПолучитьОбъект();
		Иначе
			Возврат СпрСсылка;
		КонецЕсли;	
		
	Иначе	
		
		СпрОбъект = Справочники.Контрагенты.СоздатьЭлемент();
		
	КонецЕсли;	
		
	СпрОбъект.Родитель     = Родитель;
	СпрОбъект.Наименование = Данные.Контрагент;
	СпрОбъект.ИНН          = Данные.КонтрагентИНН;
	СпрОбъект.КПП          = Данные.КонтрагентКПП;
	СпрОбъект.ДокументУдостоверяющийЛичность = СтрПаспорт;
	СпрОбъект.ЮридическоеФизическоеЛицо = ЮридическоеФизическоеЛицо;
	СпрОбъект.СтранаРегистрации         = Справочники.СтраныМира.Россия;
	СпрОбъект.Записать();
	
	Возврат СпрОбъект.Ссылка;
		
КонецФункции

Функция НайтиДоговор(Контрагент, Организация, Наименование, ВидДоговораУХ)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Наименование", Наименование);
	Запрос.Параметры.Вставить("Контрагент",   Контрагент);
	Запрос.Параметры.Вставить("Организация",  Организация);
	Запрос.Параметры.Вставить("ВидДоговораУХ", ВидДоговораУХ);
	
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Спр.Ссылка
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК Спр
	|ГДЕ
	|	Спр.Наименование = &Наименование
	|	И Спр.Владелец = &Контрагент
	|	И Спр.Организация = &Организация
	|	И Спр.ВидДоговораУХ = &ВидДоговораУХ
	|	И НЕ Спр.ПометкаУдаления";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	Иначе
		Возврат Неопределено;
	КонецЕсли;	
		
КонецФункции	

Функция ПолучитьДоговор(Данные, Перезаполнять)
	
	СпрОбъект = Неопределено;
	
	СпрСсылка = НайтиДоговор(Данные.Контрагент, Данные.Организация, Данные.Наименование, Данные.ВидДоговораУХ);
	Если ЗначениеЗаполнено(СпрСсылка) Тогда
		
		Если Перезаполнять Тогда
			СпрОбъект = СпрСсылка.ПолучитьОбъект();
		Иначе	
		
			//Реквизиты = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(СпрСсылка, "Дата, ДатаНачала, СрокДействия");
			//Если НЕ (Реквизиты.Дата = Данные.Дата
			//	И Реквизиты.ДатаНачала = Данные.ДатаНачала
			//	И Реквизиты.СрокДействия = Данные.СрокДействия) Тогда
			//	
			//	СпрОбъект = СпрСсылка.ПолучитьОбъект();
			//	
			//КонецЕсли;
			
			Возврат СпрСсылка;
		
		КонецЕсли;
		
	КонецЕсли;	
	
	Если СпрОбъект = Неопределено Тогда
		СпрОбъект = Справочники.ДоговорыКонтрагентов.СоздатьЭлемент();
	КонецЕсли;

	СпрОбъект.Владелец      = Данные.Контрагент;
	СпрОбъект.Организация   = Данные.Организация;
	СпрОбъект.ОсновнойЦФО   = Данные.ЦФО;
	СпрОбъект.Наименование  = Данные.Наименование;
	СпрОбъект.Номер         = СпрОбъект.Наименование;
	СпрОбъект.ВалютаВзаиморасчетов = ОбщегоНазначенияБПВызовСервераПовтИсп.ПолучитьВалютуРегламентированногоУчета();
	СпрОбъект.ВидДоговораУХ = Данные.ВидДоговораУХ;
	СпрОбъект.ВидДоговора   = УправлениеДоговорамиУХКлиентСерверПовтИсп.ВидДоговораБП(СпрОбъект.ВидДоговораУХ);
	СпрОбъект.ВидСоглашения = Перечисления.ВидыСоглашений.ДоговорСУсловием;
	СпрОбъект.Дата          = Данные.Дата;
	СпрОбъект.ДатаНачала    = Данные.ДатаНачала;
	СпрОбъект.СрокДействия  = Данные.СрокДействия;
	СпрОбъект.Записать();
	
	Возврат СпрОбъект.Ссылка;
		
	
КонецФункции

Функция ОсновнойДоговор(Контрагент, Организация, ВидДоговораУХ)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Владелец",      Контрагент);
	Запрос.Параметры.Вставить("Организация",   Организация);
	Запрос.Параметры.Вставить("ВидДоговораУХ", ВидДоговораУХ);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Спр.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК Спр
	|ГДЕ
	|	Спр.Владелец = &Владелец
	|	И Спр.Организация = &Организация
	|	И Спр.ВидДоговораУХ = &ВидДоговораУХ
	|	И НЕ Спр.ПометкаУдаления
	|
	|УПОРЯДОЧИТЬ ПО
	|	Ссылка УБЫВ";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	КонецЕсли;
	
КонецФункции	

#КонецОбласти

#Область Реализации

Процедура ЗагрузитьРеализации(Параметры, АдресРезультата = Неопределено) Экспорт
	
	База        = Параметры.База;
	ДатаНач     = Параметры.ДатаНач;
	ДатаКон     = Параметры.ДатаКон;
	Организация = Параметры.Организация;
	ПерезаполнятьДокументы = Параметры.ПерезаполнятьДокументы;
	
	Тест_КоличествоСтрок = 0;
	Параметры.Свойство("Тест_КоличествоСтрок", Тест_КоличествоСтрок);
	Тест_КоличествоСтрок = 10;
	
	ТипБазы   = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(База, "ТипБД"); 
	
	ДопПараметры = Новый Структура;
	ДопПараметры.Вставить("КонтрагентРодительФЛ",   Справочники.Контрагенты.НайтиПоНаименованию("1 Физические лица"));
	ДопПараметры.Вставить("КонтрагентРодительЮЛ",   Справочники.Контрагенты.НайтиПоНаименованию("1 Юридические лица"));
	ДопПараметры.Вставить("НастройкаОрганизации",   Справочники.СоответствиеВнешнимИБ.НайтиПоНаименованию("AGENTS <-> Организации",,, ТипБазы));
	ДопПараметры.Вставить("НастройкаДепартаменты",  Справочники.СоответствиеВнешнимИБ.НайтиПоНаименованию("DEPARTMENTS <-> Организации",,, ТипБазы));
	ДопПараметры.Вставить("ПерезаполнятьДокументы", ПерезаполнятьДокументы);
	ДопПараметры.Вставить("ПерезаполнятьДоговоры",  Истина);
	
	ТекстЗапроса =
	"SELECT
	|	tab.FULL_PREMIUM as FULL_PREMIUM,
	|	tab.PREMIUM_SUM as PREMIUM_SUM,
	|	tab.KV as KV,
	|	tab.KV_RUB as KV_RUB,
	|	tab.PAY_DATE as PAY_DATE,
	|	CASE WHEN tab.INSUR_TYPE = 'пролонгация' 
	|		THEN 1
	|		ELSE 0
	|	END as Пролонгация,
	|	tab.TS_NEW as TS_NEW,
	|	tab.STORONNIY_CLIENT as STORONNIY_CLIENT,
	// Номенклатура
	|	tab.PRODUCT_NAME as Номенклатура,
	// ТС
	|	tab.VIN as VIN,
	|	tab.TRANSPORT_MARK as TRANSPORT_MARK,
	|	tab.TRANSPORT_MODEL as TRANSPORT_MODEL,
	|	TO_NUMBER(tab.TRANSPORT_OUT_DATE) as TRANSPORT_OUT_DATE,
	// Контрагент
	|	tab.SUBJECT_NAME as Контрагент,
	|	tab.INSURER_INN as КонтрагентИНН,
	|	tab.INSURER_KPP as КонтрагентКПП,
	|	tab.INSURER_DOC_SERIES as КонтрагентПаспортСерия,
	|	tab.INSURER_DOC_NUMBER as КонтрагентПаспортНомер,
	|	tab.INSURER_DATE_OUT as КонтрагентПаспортДата,
	|	tab.INSURER_PLACE_OUT as КонтрагентПаспортВыдан,
	// Договор
	|	tab.POLICY_NUMBER as Договор,
	// Даты, время отбрасываем
	|	TRUNC(tab.DATE_SIGN) as Дата,
	|	TRUNC(tab.ACTION_BEGIN_DATE) as ДатаНачала,
	|	TRUNC(tab.ACTION_END_DATE) as СрокДействия,
	// Страховая
	|	tab.SK_NAME as Страховая,
	|	tab.SK_INN as СтраховаяИНН,
	|	tab.SK_KPP as СтраховаяКПП,
	// Подразделение
	|	tab.DEPARTMENT_NAME as ЦФО,
	// Банк
	|	tab.BANK as Банк,
	// Организация
	|	tab.AGENT as Организация,
	|	tab.AGENT_INN as ОрганизацияИНН
	|FROM 
	|	unicusweb_release.V_ASC_CONTRACT tab
	|WHERE
	|	tab.DATE_SIGN BETWEEN &ДатаНач AND &ДатаКон";
	
	//Доп отбор для тестирования
	// например AND rownum <= 10  - выбираем только первые 10 записей
	Если ЗначениеЗаполнено(Тест_КоличествоСтрок) Тогда
		ТекстЗапроса = ТекстЗапроса + " AND rownum <= " + Формат(Тест_КоличествоСтрок, "ЧГ=0");
		ЗаписьЖурналаРегистрации("Загрузка реализаций из Unicus",
			УровеньЖурналаРегистрации.Предупреждение, Метаданные(), , "Кол-во строк: " + Тест_КоличествоСтрок);
	КонецЕсли;	
		
	Если ЗначениеЗаполнено(Организация) Тогда
		
		ТекстЗапроса = ТекстЗапроса + "
		|	AND tab.AGENT_INN = '" + ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Организация, "ИНН") + "'";
		
	КонецЕсли;	
		
	ТекстЗапроса = ТекстЗапроса + "
	|ORDER BY
	|	DATE_SIGN, SUBJECT_NAME";
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ДатаНач", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(ДатаНач, "Oracle"));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ДатаКон", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(ДатаКон, "Oracle"));
	
	СтрокаСоединения = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(База, "СтрокаПодключения");
	
	Соединение = Новый COMОбъект("ADODB.Connection");
	Соединение.Open(СтрокаСоединения);
	
	ТаблицаДанных = ВыполнитьЗапросADO(Соединение, ТекстЗапроса);
	
	КэшДанных = Новый Структура;
	КэшДанных.Вставить("Организация",  Новый Соответствие);
	КэшДанных.Вставить("Департамент",  Новый Соответствие);
	КэшДанных.Вставить("Страховая",    Новый Соответствие);
	КэшДанных.Вставить("Номенклатура", Новый Соответствие);
	КэшДанных.Вставить("СведенияОНоменклатуре", Новый Соответствие);
	
	КэшСообщений = Новый Структура;
	КэшСообщений.Вставить("Организация",  Новый Соответствие);
	КэшСообщений.Вставить("Департамент",  Новый Соответствие);
	КэшСообщений.Вставить("Номенклатура", Новый Соответствие);
	
	Всего   = ТаблицаДанных.Количество();
	Счетчик = 0;
	Для каждого СтрокаТЗ из ТаблицаДанных Цикл
		
		СоздатьДокументРТУ(СтрокаТЗ, ДопПараметры, База, КэшДанных, КэшСообщений, Соединение);
		
		Счетчик = Счетчик + 1;
		ПроцентВыполнения = Окр(100 * Счетчик / Всего, 2);
		ДлительныеОперации.СообщитьПрогресс(ПроцентВыполнения, "Загружено " + Счетчик + " из " + Всего);
			
	КонецЦикла;	
	
КонецПроцедуры	

Функция СоздатьДокументРТУ(Данные, Параметры, База, КэшДанных, КэшСообщений, Соединение)
	
	Организация  = ПолучитьОрганизациюПоИНН(Данные.ОрганизацияИНН, КэшДанных.Организация);
	Если НЕ ЗначениеЗаполнено(Организация) Тогда
		
		Если КэшСообщений[Данные.ОрганизацияИНН] = Неопределено Тогда
			Сообщить("Не  найдена организация: " + Данные.Организация + ", ИНН: " + Данные.ОрганизацияИНН);
			КэшСообщений.Вставить(Данные.ОрганизацияИНН, Истина);
		КонецЕсли;
		
		Возврат Неопределено;
		
	КонецЕсли;	
	
	ЦФО          = ПолучитьОрганизациюПоСоотвествию(Данные.ЦФО, Параметры.НастройкаДепартаменты, База, КэшДанных.Организация);
	Контрагент   = ПолучитьКонтрагента(Данные, Параметры, Истина);
	
	ДанныеДоговора = Новый Структура;
	ДанныеДоговора.Вставить("Контрагент",    Контрагент);
	ДанныеДоговора.Вставить("Организация",   Организация);
	ДанныеДоговора.Вставить("Наименование",  Данные.Договор);
	ДанныеДоговора.Вставить("ЦФО",           ЦФО);
	ДанныеДоговора.Вставить("ВидДоговораУХ", Перечисления.ВидыДоговоровКонтрагентовУХ.СПокупателем);
	ДанныеДоговора.Вставить("Дата",          Данные.Дата);
	ДанныеДоговора.Вставить("ДатаНачала",    Данные.ДатаНачала);
	ДанныеДоговора.Вставить("СрокДействия",  Данные.СрокДействия);
	
	Договор      = ПолучитьДоговор(ДанныеДоговора, Параметры.ПерезаполнятьДоговоры);

	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Договор", Договор);
	Запрос.Параметры.Вставить("Дата1",   Данные.Дата);
	Запрос.Параметры.Вставить("Дата2",   КонецДня(Данные.Дата));
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Док.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК Док
	|ГДЕ
	|	Док.ДоговорКонтрагента = &Договор
	|	И НЕ Док.ПометкаУдаления
	|	И Док.Дата МЕЖДУ &Дата1 И &Дата2";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		
		ДокументСсылка = Результат.Выгрузить()[0][0];
		
		Если Параметры.ПерезаполнятьДокументы = Истина Тогда
			ДокументОбъект = ДокументСсылка.ПолучитьОбъект();
			ДокументОбъект.Проведен = Ложь;
		Иначе
			Возврат ДокументСсылка;
		КонецЕсли;
		
	Иначе
		ДокументОбъект = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
	КонецЕсли;
	
	Номенклатура = ПолучитьНоменклатуру(Данные.Номенклатура, КэшДанных.Номенклатура);
	
	ВремяДокумента = Документы.РеализацияТоваровУслуг.ВремяДокументаПоУмолчанию();
	
	ДокументОбъект.Организация = Организация;
	ДокументОбъект.Дата        = Данные.Дата + 3600 * ВремяДокумента.Часы + 60 * ВремяДокумента.Минуты;
	ДокументОбъект.Контрагент  = Контрагент;
	ДокументОбъект.ДоговорКонтрагента = Договор;
	
	ДокументОбъект.ВалютаДокумента = Константы.ВалютаРегламентированногоУчета.Получить();
	ДокументОбъект.ВидОперации     = Перечисления.ВидыОперацийРеализацияТоваров.ПродажаКомиссия;
	ДокументОбъект.СчетУчетаРасчетовСКонтрагентом = ПланыСчетов.Хозрасчетный.РасчетыСПрочимиПоставщикамиИПодрядчиками;
	ДокументОбъект.СчетУчетаРасчетовПоАвансам     = ПланыСчетов.Хозрасчетный.РасчетыСПрочимиПоставщикамиИПодрядчиками;
	ДокументОбъект.СпособЗачетаАвансов = Перечисления.СпособыЗачетаАвансов.Автоматически;
	
	ДокументОбъект.Услуги.Очистить();
	ДокументОбъект.АгентскиеУслуги.Очистить();
	
	ПараметрыОбъекта = Новый Структура;
	ПараметрыОбъекта.Вставить("Дата",        Данные.Дата);
	ПараметрыОбъекта.Вставить("Организация", Организация);
	
	СведенияОНоменклатуре = КэшДанных.СведенияОНоменклатуре[Номенклатура];
	Если СведенияОНоменклатуре = Неопределено Тогда
		СведенияОНоменклатуре = БухгалтерскийУчетПереопределяемый.ПолучитьСведенияОНоменклатуре(Номенклатура, ПараметрыОбъекта);
		КэшДанных.СведенияОНоменклатуре.Вставить(Номенклатура, СведенияОНоменклатуре);
	КонецЕсли;	
	
	// Услуги
	НоваяСтрока = ДокументОбъект.Услуги.Добавить();
	НоваяСтрока.Номенклатура = Номенклатура;
	НоваяСтрока.Содержание   = Данные.VIN;
	НоваяСтрока.Сумма        = Данные.KV_RUB;
	НоваяСтрока.СтавкаНДС    = Перечисления.СтавкиНДС.БезНДС;
	НоваяСтрока.СчетДоходов  = СведенияОНоменклатуре.СчетаУчета.СчетДоходов;
	НоваяСтрока.СчетРасходов = СведенияОНоменклатуре.СчетаУчета.СчетРасходов;
	НоваяСтрока.СчетУчетаНДСПоРеализации = СведенияОНоменклатуре.СчетаУчета.СчетУчетаНДСПродажи;
	НоваяСтрока.Субконто     = СведенияОНоменклатуре.НоменклатурнаяГруппа;
	
	Если НЕ ЗначениеЗаполнено(НоваяСтрока.СчетРасходов) Тогда
		НоваяСтрока.СчетРасходов = ПланыСчетов.Хозрасчетный.СебестоимостьПродажНеЕНВД; //90.02.1
	КонецЕсли;	
	
	Если НЕ ЗначениеЗаполнено(НоваяСтрока.СчетДоходов) Тогда
		НоваяСтрока.СчетДоходов = ПланыСчетов.Хозрасчетный.ВыручкаНеЕНВД; //90.01.1
	КонецЕсли;	
	
	Если НЕ ЗначениеЗаполнено(НоваяСтрока.СчетУчетаНДСПоРеализации) Тогда
		НоваяСтрока.СчетУчетаНДСПоРеализации = ПланыСчетов.Хозрасчетный.Продажи_НДС; //90.03
	КонецЕсли;	
	
	
	// АгентскиеУслуги
	ТекстОшибки = "";
	СК = АСЦ_ОбщийМодуль.НайтиКонтрагента(Данные.Страховая, Данные.СтраховаяИНН, Данные.СтраховаяКПП, ТекстОшибки);
	
	НоваяСтрока = ДокументОбъект.АгентскиеУслуги.Добавить();
	НоваяСтрока.Номенклатура = Номенклатура;
	НоваяСтрока.Содержание   = Данные.VIN;
	НоваяСтрока.Сумма        = Данные.PREMIUM_SUM - Данные.KV_RUB;
	НоваяСтрока.СтавкаНДС    = Перечисления.СтавкиНДС.БезНДС;
	НоваяСтрока.Контрагент   = СК;
	НоваяСтрока.ДоговорКонтрагента = ОсновнойДоговор(НоваяСтрока.Контрагент, ДокументОбъект.Организация, Перечисления.ВидыДоговоровКонтрагентовУХ.СКомитентом);
	НоваяСтрока.СчетРасчетов = ПланыСчетов.Хозрасчетный.НайтиПоКоду("76.01.1");
	
	// Без договора не проведется
	ДокументОбъект.Проведен = Ложь;
	ЗаписатьДокумент(ДокументОбъект);				
	
	Возврат ДокументОбъект.Ссылка;
	
КонецФункции

#КонецОбласти

#Область Отчеты

Процедура ЗагрузитьОтчеты(Параметры, АдресРезультата = Неопределено) Экспорт
	
	База        = Параметры.База;
	ДатаНач     = Параметры.ДатаНач;
	ДатаКон     = Параметры.ДатаКон;
	Организация = Параметры.Организация;
	ПерезаполнятьДокументы = Параметры.ПерезаполнятьДокументы;
	
	Тест_КоличествоСтрок = 0;
	Параметры.Свойство("Тест_КоличествоСтрок", Тест_КоличествоСтрок);
	Тест_КоличествоСтрок = 10;
	
	ТипБазы   = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(База, "ТипБД"); 
	
	ДопПараметры = Новый Структура;
	ДопПараметры.Вставить("КонтрагентРодитель",    Справочники.Контрагенты.НайтиПоНаименованию("1 Физические лица"));
	ДопПараметры.Вставить("НастройкаОрганизации",  Справочники.СоответствиеВнешнимИБ.НайтиПоНаименованию("AGENTS <-> Организации",,, ТипБазы));
	ДопПараметры.Вставить("ПерезаполнятьДокументы", ПерезаполнятьДокументы);
	
	ТекстЗапроса =
	"SELECT 
	|    TO_CHAR(head.act_id) as ИД,    
	|    head.НомерДок,    
	|    head.ДатаДок,    
	|    head.СК,  
	|    head.СК_Договор,  
	|    tab.SK_INN as СК_ИНН,
	|    tab.SK_KPP as СК_КПП,
	|    TO_NUMBER(tab.COL2) as НомерСтроки,
	|	 tab.AGENT_INN as ОрганизацияИНН,
	|    tab.COL3 as Контрагент,
	|    tab.COL10 as КонтрагентИНН,
	|    tab.COL11 as КонтрагентКПП,
	|    tab.COL4 as Серия,
	|    tab.COL5 as Номер,
	|    TO_NUMBER(tab.COL6, '999999999999.99') as СтраховаяПремия,
	|    tab.COL7 as КВ_руб,
	|    tab.COL8 as КВ,
	|    tab.COL9 as СуммаКПеречислению,
    |	(SELECT 
	|        contract.PRODUCT_NAME
	|     FROM    
	|        V_ASC_CONTRACT contract
	|     WHERE
	|        contract.POLICY_NUMBER = CONCAT(tab.COL4, tab.COL5)
	|        AND rownum = 1) AS PRODUCT_NAME
	|FROM
	|	(SELECT 
	|   	ACT_ID, 
	|	    COL2 as НомерДок, 
	|   	TO_DATE(COL3, 'DD.MM.YYYY') as  ДатаДок,
	|	    COL4 as СК,
	|	    COL6 as СК_Договор
	|	FROM v_asc_act
	|	WHERE
	|		COL1 is NOT NULL
	|		AND TO_DATE(COL3, 'DD.MM.YYYY') BETWEEN &ДатаНач AND &ДатаКон) head
	|	LEFT JOIN v_asc_act tab 
	|		ON tab.act_id = head.act_id
	|WHERE
	|	tab.COL1 IS NULL";
	
	//Доп отбор для тестирования
	// например AND rownum <= 10  - выбираем только первые 10 записей
	Если ЗначениеЗаполнено(Тест_КоличествоСтрок) Тогда
		ТекстЗапроса = ТекстЗапроса + " AND rownum <= " + Формат(Тест_КоличествоСтрок, "ЧГ=0");
		ЗаписьЖурналаРегистрации("Загрузка реализаций из Unicus",
			УровеньЖурналаРегистрации.Предупреждение, Метаданные(), , "Кол-во строк: " + Тест_КоличествоСтрок);
	КонецЕсли;	
		
	Если ЗначениеЗаполнено(Организация) Тогда
		
		ТекстЗапроса = ТекстЗапроса + "
		|	AND tab.AGENT_INN = '" + ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Организация, "ИНН") + "'";
		
	КонецЕсли;	
		
	ТекстЗапроса = ТекстЗапроса + "
	|ORDER BY
	|	ДатаДок, ИД, НомерСтроки";
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ДатаНач", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(ДатаНач, "Oracle"));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ДатаКон", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(ДатаКон, "Oracle"));
	
	СтрокаСоединения = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(База, "СтрокаПодключения");
	
	Соединение = Новый COMОбъект("ADODB.Connection");
	Соединение.Open(СтрокаСоединения);
	
	ТаблицаДанных = ВыполнитьЗапросADO(Соединение, ТекстЗапроса);
	
	КэшДанных = Новый Структура;
	КэшДанных.Вставить("Организация",  Новый Соответствие);
	КэшДанных.Вставить("Номенклатура", Новый Соответствие);
	
	КэшСообщений = Новый Структура;
	КэшСообщений.Вставить("Организация",  Новый Соответствие);
	КэшСообщений.Вставить("Департамент",  Новый Соответствие);
	КэшСообщений.Вставить("Номенклатура", Новый Соответствие);
	
	Всего   = ТаблицаДанных.Количество();
	Счетчик = 0;
	
	ПредЗначения = Новый Структура("ИД");
	ДокОбъект    = Неопределено;
	
	Для каждого СтрокаТЗ из ТаблицаДанных Цикл
		
		Если ЗначенияОтличаются(ПредЗначения, СтрокаТЗ) Тогда
			
			ЗаполнитьЗначенияСвойств(ПредЗначения, СтрокаТЗ);
			
			
			ЗаписатьДокумент(ДокОбъект);
			//ЗаполнитьСвязанныеДокументыОтчетПосредника(ДокОбъект);
			
			ДокОбъект = СоздатьДокументОтчетПосредника(СтрокаТЗ, ДопПараметры, База, КэшДанных, КэшСообщений);
			
			Если Ложь Тогда
				ДокОбъект = Документы.АСЦ_ОтчетПосредника.СоздатьДокумент();
			КонецЕсли;	
			
			// Неопределено когда документ не перезаполняем
			Если ДокОбъект <> Неопределено Тогда
				
				ДокОбъект.Дата        = СтрокаТЗ.ДатаДок;
				ДокОбъект.Организация = ПолучитьОрганизациюПоИНН(СтрокаТЗ.ОрганизацияИНН, КэшДанных.Организация);
				
				ТекстОшибки = "";
				ДокОбъект.Контрагент  = АСЦ_ОбщийМодуль.НайтиКонтрагента("", СтрокаТЗ.СК_ИНН, СтрокаТЗ.СК_КПП, ТекстОшибки);
				Если ЗначениеЗаполнено(ДокОбъект.Контрагент) Тогда
				
					ДанныеДоговора = Новый Структура;
					ДанныеДоговора.Вставить("Контрагент",    ДокОбъект.Контрагент);
					ДанныеДоговора.Вставить("Организация",   ДокОбъект.Организация);
					ДанныеДоговора.Вставить("Наименование",  СтрокаТЗ.СК_Договор);
					ДанныеДоговора.Вставить("ЦФО",           Неопределено);
					ДанныеДоговора.Вставить("ВидДоговораУХ", Перечисления.ВидыДоговоровКонтрагентовУХ.СКомитентом);
					ДанныеДоговора.Вставить("Дата",          "");
					ДанныеДоговора.Вставить("ДатаНачала",    "");
					ДанныеДоговора.Вставить("СрокДействия",  "");
	
					ДокОбъект.ДоговорКонтрагента = ПолучитьДоговор(ДанныеДоговора, Ложь);
					
				КонецЕсли;
				
				ДокОбъект.ID_Unicus   = СтрокаТЗ.ИД;
				
			КонецЕсли;
			
		КонецЕсли;	
		
		Счетчик = Счетчик + 1;
		ПроцентВыполнения = Окр(100 * Счетчик / Всего, 2);
		ДлительныеОперации.СообщитьПрогресс(ПроцентВыполнения, "" + Организация + ": " + Счетчик + " из " + Всего);
		
		Если ДокОбъект <> Неопределено Тогда
			
			// Тут заполнение таб. части
			НоваяСтрока = ДокОбъект.Продажи.Добавить();
			НоваяСтрока.Контрагент         = АСЦ_ОбщийМодуль.НайтиКонтрагента(СтрокаТЗ.Контрагент, СтрокаТЗ.КонтрагентИНН, СтрокаТЗ.КонтрагентКПП, ТекстОшибки);
			Если ЗначениеЗаполнено(НоваяСтрока.Контрагент) Тогда
				НоваяСтрока.ДоговорКонтрагента = НайтиДоговор(НоваяСтрока.Контрагент, ДокОбъект.Организация, СтрокаТЗ.Серия + СтрокаТЗ.Номер, Перечисления.ВидыДоговоровКонтрагентовУХ.СПокупателем);
			КонецЕсли;	
			НоваяСтрока.Номенклатура       = ПолучитьНоменклатуру(СтрокаТЗ.PRODUCT_NAME, КэшДанных.Номенклатура);
			НоваяСтрока.СуммаОплаты        = СтрокаТЗ.СтраховаяПремия;
			НоваяСтрока.СуммаКВ            = СтрокаТЗ.КВ_руб;
			
		КонецЕсли;
		
	КонецЦикла;	
	
	ДокОбъект.ЗаполнитьСвязанныеДокументы();
	ЗаписатьДокумент(ДокОбъект);
		
КонецПроцедуры	

Функция СоздатьДокументОтчетПосредника(Данные, Параметры, База, КэшДанных, КэшСообщений)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("ИД", Данные.ИД); 
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Док.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.АСЦ_ОтчетПосредника КАК Док
	|ГДЕ
	|	Док.ID_Unicus = &ИД";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		
		ДокументСсылка = Результат.Выгрузить()[0][0];
		
		Если Параметры.ПерезаполнятьДокументы = Истина Тогда
			ДокументОбъект = ДокументСсылка.ПолучитьОбъект();
			ДокументОбъект.Продажи.Очистить();
			ДокументОбъект.Проведен = Ложь;
		Иначе
			Возврат Неопределено;
		КонецЕсли;
		
	Иначе
		ДокументОбъект = Документы.АСЦ_ОтчетПосредника.СоздатьДокумент();
	КонецЕсли;
	
	Возврат ДокументОбъект;
	
КонецФункции	

#КонецОбласти

