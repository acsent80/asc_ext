﻿
////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЙ ПРОГРАММНЫЙ ИНТЕРФЕЙС

&НаСервере
Процедура УстановитьСостояниеДокумента()
	
	СостояниеДокумента = ОбщегоНазначенияБП.СостояниеДокумента(Объект);
	
КонецПроцедуры

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	УстановитьСостояниеДокумента();
	
	УстановитьЗаголовкиТаблицы();
	УстановитьУсловноеОформление();
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	ПрочитатьДатыЗакрытияПериода();
	
	// СтандартныеПодсистемы.ДатыЗапретаИзменения
	ДатыЗапретаИзменения.ОбъектПриЧтенииНаСервере(ЭтаФорма, ТекущийОбъект);
	// Конец СтандартныеПодсистемы.ДатыЗапретаИзменения
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	СтрукутраОтбора = Новый Структура("Контрагент, ДЦ");
	Для каждого СтрокаТЧ из ТекущийОбъект.Проценты Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Период) Тогда
			Продолжить;
		КонецЕсли;	
		
		ЗаполнитьЗначенияСвойств(СтрукутраОтбора, СтрокаТЧ);
		НайденныеСтроки = Таблица.НайтиСтроки(СтрукутраОтбора);
		Если НайденныеСтроки.Количество() = 0 Тогда
			НоваяСтрока = Таблица.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрукутраОтбора);
		Иначе
			НоваяСтрока = НайденныеСтроки[0];
		КонецЕсли;	
		
		НомерМесяца = Месяц(СтрокаТЧ.Период);
		НоваяСтрока["Процент" + НомерМесяца] = СтрокаТЧ.ПроцентКВ;
		
				
	КонецЦикла;	
	
	Для каждого СтрокаТЧ из Таблица Цикл
		
		СтрокиДатЗапрета = ТаблицаДатЗапретаИзмененияПериода.НайтиСтроки(Новый Структура("ДЦ", СтрокаТЧ.ДЦ));
		Если СтрокиДатЗапрета.Количество() = 0 Тогда
			СтрокиДатЗапрета = ТаблицаДатЗапретаИзмененияПериода.НайтиСтроки(Новый Структура("ДЦ", Справочники.Организации.ПустаяСсылка()));
		КонецЕсли;	
		
		Если СтрокиДатЗапрета.Количество() > 0 Тогда
			
			СтрокаТЧ.ДатаЗапрета = СтрокиДатЗапрета[0].Дата;
			
			НомерМесяца = Месяц(СтрокаТЧ.ДатаЗапрета);
			Для Счетчик = 1 по НомерМесяца Цикл
				СтрокаТЧ["ПериодЗакрыт" + Счетчик] = Истина;
			КонецЦикла;	
			
		КонецЕсли;	
		
	КонецЦикла;	
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	НомерГода = ПолучитьНомерГода(Объект.Период);
	
	ТекущийОбъект.Проценты.Очистить();
	Для каждого СтрокаТЗ из Таблица Цикл
		
		Для Счетчик = 1 По 12 Цикл
			
			ПроцентКВ = СтрокаТЗ["Процент" + Счетчик];
			Если ПроцентКВ = 0 Тогда
				Продолжить;
			КонецЕсли;	
			
			НоваяСтрока = ТекущийОбъект.Проценты.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТЗ); 
			
			НоваяСтрока.Период = Дата(НомерГода, Счетчик, 1);
			НоваяСтрока.ПроцентКВ = ПроцентКВ;
			
		КонецЦикла;	
		
	КонецЦикла;	
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	УстановитьСостояниеДокумента();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

#КонецОбласти

&НаСервере
Процедура УстановитьЗаголовкиТаблицы()
	
	НачалоПериода = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.Период, "ДатаНачала");
	Если НЕ ЗначениеЗаполнено(НачалоПериода) Тогда
		НачалоПериода = НачалоГода(ТекущаяДата());
	КонецЕсли;	
	
	НомерГода = Год(НачалоПериода);
	
	Для Счетчик = 1 По 12 Цикл
		
		Элементы["ТаблицаПроцент" + Счетчик].Заголовок = Формат(Дата(НомерГода, Счетчик, 1), "ДФ='MMMM yy'");
		
	КонецЦикла;	
	
КонецПроцедуры

&НаСервере
Процедура УстановитьУсловноеОформление()
	
	ЭлементУО = УсловноеОформление.Элементы.Добавить();
	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТаблицаДЦ");
	
	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ЭлементУО.Отбор,
		"Таблица.ДЦ", ВидСравненияКомпоновкиДанных.НеЗаполнено);
	
	ЭлементУО.Оформление.УстановитьЗначениеПараметра("Текст",      "По всем ДЦ");
	ЭлементУО.Оформление.УстановитьЗначениеПараметра("ЦветТекста", ЦветаСтиля.ЦветНедоступногоТекста);
	
	Для Счетчик = 1 по 12 Цикл
		
		// Закрытый период
		ЭлементУО = УсловноеОформление.Элементы.Добавить();
		КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТаблицаПроцент" + Счетчик);
		
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ЭлементУО.Отбор,
			"Таблица.ПериодЗакрыт" + Счетчик, ВидСравненияКомпоновкиДанных.Равно, Истина);
		
		ЭлементУО.Оформление.УстановитьЗначениеПараметра("ЦветТекста",     ЦветаСтиля.ЦветНедоступногоТекста);
		ЭлементУО.Оформление.УстановитьЗначениеПараметра("ТолькоПросмотр", Истина);
		
		// Измененные элементы
		ЭлементУО = УсловноеОформление.Элементы.Добавить();
		КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТаблицаПроцент" + Счетчик);
		
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ЭлементУО.Отбор,
			"Таблица.Изменен" + Счетчик, ВидСравненияКомпоновкиДанных.Равно, Истина);
		
		ЭлементУО.Оформление.УстановитьЗначениеПараметра("Шрифт", Новый Шрифт(,, Истина));
		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчитатьДокументыИзмененные(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПересчитатьДокументыИзмененныеЗавершение", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, "Пересчитать документы по измененным процентам?", РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Нет);
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчитатьДокументыИзмененныеЗавершение(Ответ, ДопПараметры) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;	
	
	ПересчитатьДокументыИзмененныеСервер();
	
КонецПроцедуры

&НаСервере
Процедура ПересчитатьДокументыИзмененныеСервер()
	
	ДЦИсключения = Новый Соответствие;
	Для каждого СтрокаТЗ из Таблица Цикл
		
		СписокЗначений = ДЦИсключения[СтрокаТЗ.Контрагент];
		Если СписокЗначений = Неопределено Тогда
			СписокЗначений = Новый СписокЗначений;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(СтрокаТЗ.ДЦ) Тогда
			СписокЗначений.Добавить(СтрокаТЗ.ДЦ);
			ДЦИсключения[СтрокаТЗ.Контрагент] = СписокЗначений;
		КонецЕсли;	
		
	КонецЦикла;	
	
	НомерГода = ПолучитьНомерГода(Объект.Период);
	Для каждого СтрокаТЗ из Таблица Цикл
		
		Для Счетчик = 1 по 12 Цикл
			
			Если СтрокаТЗ["Изменен" + Счетчик] Тогда
				
				ДатаНач = Дата(НомерГода, Счетчик, 1);
				ПроцентКВ = СтрокаТЗ["Процент" + Счетчик];
				
				Документы.АСЦ_ПлановоеНачислениеКВ.ПересчитатьДокументы(ДатаНач, КонецМесяца(ДатаНач), 
					Объект.Организация, СтрокаТЗ.Контрагент, СтрокаТЗ.ДЦ, ДЦИсключения[СтрокаТЗ.Контрагент], ПроцентКВ);
			КонецЕсли;	
			
		КонецЦикла;	
		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчитатьДокументыВсе(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПересчитатьДокументыВсеЗавершение", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, "Пересчитать документы по всем открытым периодам?", РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Нет);
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчитатьДокументыВсеЗавершение(Ответ, ДопПараметры) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;	
	
	ПересчитатьДокументыВсеСервер();
	
КонецПроцедуры

&НаСервере
Процедура ПересчитатьДокументыВсеСервер()
	
	ДЦИсключения = Новый Соответствие;
	Для каждого СтрокаТЗ из Таблица Цикл
		
		СписокЗначений = ДЦИсключения[СтрокаТЗ.Контрагент];
		Если СписокЗначений = Неопределено Тогда
			СписокЗначений = Новый СписокЗначений;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(СтрокаТЗ.ДЦ) Тогда
			СписокЗначений.Добавить(СтрокаТЗ.ДЦ);
			ДЦИсключения[СтрокаТЗ.Контрагент] = СписокЗначений;
		КонецЕсли;	
		
	КонецЦикла;	
	
	НомерГода = ПолучитьНомерГода(Объект.Период);
	Для каждого СтрокаТЗ из Таблица Цикл
		
		Для Счетчик = 1 по 12 Цикл
			
			Если НЕ СтрокаТЗ["ПериодЗакрыт" + Счетчик] Тогда
				
				ДатаНач = Дата(НомерГода, Счетчик, 1);
				ПроцентКВ = СтрокаТЗ["Процент" + Счетчик];
				
				Документы.АСЦ_ПлановоеНачислениеКВ.ПересчитатьДокументы(ДатаНач, КонецМесяца(ДатаНач), 
					Объект.Организация, СтрокаТЗ.Контрагент, СтрокаТЗ.ДЦ, ДЦИсключения[СтрокаТЗ.Контрагент], ПроцентКВ);
			КонецЕсли;	
			
		КонецЦикла;	
		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПроцентВСтроке(Команда)
	
	ТекущиеДанные = Элементы.Таблица.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТекущаяКолонка = Элементы.Таблица.ТекущийЭлемент;
	НомерКолонки = Число(СтрЗаменить(ТекущаяКолонка.Имя, "ТаблицаПроцент", ""));
	Значение = ТекущиеДанные["Процент" + НомерКолонки];
	
	Для Счетчик = НомерКолонки + 1 по 12 Цикл
		
		Если ТекущиеДанные["ПериодЗакрыт" + Счетчик] Тогда
			Продолжить;
		КонецЕсли;	
		
		ТекущиеДанные["Процент" + Счетчик] = Значение;
		ТекущиеДанные["Изменен" + Счетчик] = Истина;
		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура ПериодПриИзменении(Элемент)
	
	УстановитьЗаголовкиТаблицы();
	
КонецПроцедуры

&НаСервере
Процедура ПрочитатьДатыЗакрытияПериода(Перечитать = Ложь)
	
	Если ТаблицаДатЗапретаИзмененияПериода.Количество() > 0
		И Перечитать = Ложь Тогда
		Возврат;
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Раздел", ПланыВидовХарактеристик.РазделыДатЗапретаИзменения.НайтиПоНаименованию("Учет по МСФО"));
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ВЫБОР 
	|		КОГДА ДатыЗапретаИзменения.Объект ССЫЛКА Справочник.Организации 
	|			ТОГДА ДатыЗапретаИзменения.Объект 
	|		ИНАЧЕ 
	|			ЗНАЧЕНИЕ(Справочник.Организации.ПустаяСсылка) 
	|	КОНЕЦ КАК ДЦ,
	|	КОНЕЦПЕРИОДА(ДатыЗапретаИзменения.ДатаЗапрета, ДЕНЬ) КАК Дата
	|ИЗ
	|	РегистрСведений.ДатыЗапретаИзменения КАК ДатыЗапретаИзменения
	|ГДЕ
	|	ДатыЗапретаИзменения.Пользователь = ЗНАЧЕНИЕ(Перечисление.ВидыНазначенияДатЗапрета.ДляВсехПользователей)
	|	И ДатыЗапретаИзменения.Раздел = &Раздел";
	
	ТаблицаДатЗапретаИзмененияПериода.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры	

&НаКлиенте
Процедура ТаблицаДЦПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.Таблица.ТекущиеДанные;
	
	СтрокиДатЗапрета = ТаблицаДатЗапретаИзмененияПериода.НайтиСтроки(Новый Структура("ДЦ", ТекущиеДанные.ДЦ));
	Если СтрокиДатЗапрета.Количество() = 0 Тогда
		
		Для Счетчик = 1 по 12 Цикл
			ТекущиеДанные["ПериодЗакрыт" + Счетчик] = Ложь;
		КонецЦикла;	
		
	Иначе
		НомерГода = ПолучитьНомерГода(Объект.Период);
		Для Счетчик = 1 по 12 Цикл
			Период = Дата(НомерГода, Счетчик, 1);
			ТекущиеДанные.ДатаЗапрета = СтрокиДатЗапрета[0].Дата;
			ТекущиеДанные["ПериодЗакрыт" + Счетчик] = (Период <= ТекущиеДанные.ДатаЗапрета);
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСерверебезКонтекста
Функция ПолучитьНомерГода(Период)
	
	НачалоПериода = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Период, "ДатаНачала");
	Возврат Год(НачалоПериода);
	
КонецФункции

&НаКлиенте
Процедура ТаблицаПроцентПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.Таблица.ТекущиеДанные;
	
	Номер = СтрЗаменить(Элемент.Имя, "ТаблицаПроцент", "");
	ТекущиеДанные["Изменен" + Номер] = Истина;
	
КонецПроцедуры

