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
	
	Период.ДатаНачала    = Объект.ДатаНач;
	Период.ДатаОкончания = Объект.ДатаКон;
	
	УстановитьВидимость(ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	// СтандартныеПодсистемы.ДатыЗапретаИзменения
	ДатыЗапретаИзменения.ОбъектПриЧтенииНаСервере(ЭтаФорма, ТекущийОбъект);
	// Конец СтандартныеПодсистемы.ДатыЗапретаИзменения
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	ТекущийОбъект.ДатаНач = Период.ДатаНачала;
	ТекущийОбъект.ДатаКон = Период.ДатаОкончания;
	
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

// СтандартныеПодсистемы.ПодключаемыеКоманды
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
	ПодключаемыеКомандыКлиент.ВыполнитьКоманду(ЭтотОбъект, Команда, Объект);
КонецПроцедуры

&НаСервере
Процедура Подключаемый_ВыполнитьКомандуНаСервере(Контекст, Результат)
	ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, Контекст, Объект, Результат);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

&НаКлиенте
Процедура ПродажиСуммаПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.Продажи.ТекущиеДанные;
	ТекущиеДанные.ПроцентКВ = Окр(100 * ТекущиеДанные.СуммаКВ / ТекущиеДанные.Сумма, 2); 
	
КонецПроцедуры

&НаКлиенте
Процедура ПродажиПроцентКВПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.Продажи.ТекущиеДанные;
	ТекущиеДанные.СуммаКВ = Окр(ТекущиеДанные.Сумма * ТекущиеДанные.ПроцентКВ / 100, 2); 
	
КонецПроцедуры

&НаКлиенте
Процедура ПродажиСуммаКВПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.Продажи.ТекущиеДанные;
	
	Если ТекущиеДанные.Сумма <> 0 Тогда
		ТекущиеДанные.ПроцентКВ = Окр(100 * ТекущиеДанные.СуммаКВ / ТекущиеДанные.Сумма, 2); 
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура Подбор(Команда)
	
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("Организация", Объект.Организация);
	СтруктураОтбора.Вставить("Комитент",    Объект.Контрагент);
	СтруктураОтбора.Вставить("ВидОперации", Объект.ВидОперации);
	СтруктураОтбора.Вставить("ПометкаУдаления", Ложь);
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Отбор",              СтруктураОтбора);
	ПараметрыФормы.Вставить("ЗакрыватьПриВыборе", Ложь);
	ПараметрыФормы.Вставить("МножественныйВыбор", Истина);
	ПараметрыФормы.Вставить("Период",             Период);
	
	ОткрытьФорму("Документ.АСЦ_ПлановоеНачислениеКВ.ФормаВыбора", ПараметрыФормы, Элементы.Продажи,,,,,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

&НаКлиенте
Процедура ПродажиОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	СтруктураОтбора = Новый Структура("Документ");
	
	Для каждого Значение из ВыбранноеЗначение Цикл
		
		СтруктураОтбора.Документ = Значение;
		НайденныеСтроки = Объект.Продажи.НайтиСтроки(СтруктураОтбора);
		Если НайденныеСтроки.Количество() = 0 Тогда
			НоваяСтрока = Объект.Продажи.Добавить();
			НоваяСтрока.Документ = Значение;
			ПриИзмененииДокумента(НоваяСтрока.ПолучитьИдентификатор());
		КонецЕсли;	
		
	КонецЦикла;	
	
КонецПроцедуры

&НаСервере
Процедура ПриИзмененииДокумента(ИдСтроки)
	
	СтрокаТЧ = Объект.Продажи.НайтиПоИдентификатору(ИдСтроки);
	Если СтрокаТЧ = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Реквизиты = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(СтрокаТЧ.Документ, "Сумма, ПроцентКВ, СуммаКВ, Реализация, ДЦ, Статья");
	СтрокаТЧ.Реализация = Реквизиты.Реализация;
	СтрокаТЧ.ДЦ         = Реквизиты.ДЦ;
	СтрокаТЧ.Статья     = Реквизиты.Статья;
	
	СтрокаТЧ.СуммаПлан     = Реквизиты.Сумма;
	СтрокаТЧ.ПроцентКВПлан = Реквизиты.ПроцентКВ;
	СтрокаТЧ.СуммаКВПлан   = Реквизиты.СуммаКВ;
	
КонецПроцедуры	

&НаКлиенте
Процедура ПродажиДокументПриИзменении(Элемент)
	
	ПриИзмененииДокумента(Элементы.Продажи.ТекущаяСтрока);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьИзExcel(Команда)
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("Контрагент", Объект.Контрагент);
	СтруктураПараметров.Вставить("Таблица",    Объект.Продажи);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗагрузитьИзExcelЗавершение", ЭтотОбъект);
	
	ОткрытьФорму("Обработка.АСЦ_ЗагрузкаИзExcel.Форма", СтруктураПараметров, ЭтаФорма,,,, ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьИзExcelЗавершение(Результат, ДопПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;	
	
	ЗагрузитьИзExcelСервер(Результат);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьИзExcelСервер(Результат)
	
	Для каждого СтрокаТЗ из Объект.Продажи Цикл
		
		Контрагент = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаТЗ.Реализация, "Контрагент");
		НайденныеСтроки = Результат.НайтиСтроки(Новый Структура("КонтрагентДок", Контрагент));
		Если НайденныеСтроки.Количество() > 0 Тогда
			
			СтрокаТЗ.Сумма   = НайденныеСтроки[0].Сумма;
			СтрокаТЗ.СуммаКВ = НайденныеСтроки[0].СуммаКВ;
			
			Если ЗначениеЗаполнено(НайденныеСтроки[0].ПроцентКВ) Тогда
				СтрокаТЗ.ПроцентКВ = НайденныеСтроки[0].ПроцентКВ;
				
			ИначеЕсли СтрокаТЗ.Сумма > 0 Тогда	
				СтрокаТЗ.ПроцентКВ = Окр(100 * СтрокаТЗ.СуммаКВ / СтрокаТЗ.Сумма, 2);
			КонецЕсли;
			
		КонецЕсли;	
		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДокументы(Команда)
	
	Если Объект.Продажи.Количество() > 0 Тогда
		
		ОписаниеОповещения = Новый ОписаниеОповещения("ЗаполнитьДокументыЗавершение", ЭтотОбъект);
		ПоказатьВопрос(ОписаниеОповещения, "Перед заполнением табличная часть будет очищена.
		|Продолжить?", РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Да);
		
	Иначе
		ЗаполнитьДокументыЗавершение(КодВозвратаДиалога.Да, Неопределено);
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДокументыЗавершение(Ответ, ДопПараметры) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;	
	
	ЗаполнитьДокументыСервер();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДокументыСервер()
	
	Таблица = Документы.АСЦ_ПлановоеНачислениеКВ.ПолучитьНепривязанныеДокументы(Период.ДатаНачала, Период.ДатаОкончания, 
		Объект.Организация, Объект.Контрагент, Объект.ВидОперации, Объект.Ссылка);
	
	Объект.Продажи.Загрузить(Таблица);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПроцентПоВсем(Команда)
	
	Если ПроцентКВ = 0 Тогда
		Возврат;
	КонецЕсли;	
	
	ДопПараметры = Новый Структура;
	ДопПараметры.Вставить("Строки", Объект.Продажи);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗаполнитьПроцентПоВсемЗавершение", ЭтотОбъект, ДопПараметры);
	ПоказатьВопрос(ОписаниеОповещения, "Заполнить процент по всем строкам?", РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Да);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПроцентПоВыделенным(Команда)
	
	Если ПроцентКВ = 0 Тогда
		Возврат;
	КонецЕсли;	
	
	МассивСтрок = Новый Массив;
	Для каждого ИДСтроки из Элементы.Продажи.ВыделенныеСтроки Цикл
		МассивСтрок.Добавить(Объект.Продажи.НайтиПоИдентификатору(ИДСтроки));
	КонецЦикла;
	
	ДопПараметры = Новый Структура;
	ДопПараметры.Вставить("Строки", МассивСтрок);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗаполнитьПроцентПоВсемЗавершение", ЭтотОбъект, ДопПараметры);
	ПоказатьВопрос(ОписаниеОповещения, "Заполнить процент по выделенным строкам?", РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Да);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПроцентПоВсемЗавершение(Ответ, ДопПараметры) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;	
	
	Для каждого СтрокаТЗ из ДопПараметры.Строки Цикл
		
		СтрокаТЗ.ПроцентКВ = ПроцентКВ;
		СтрокаТЗ.СуммаКВ = Окр(СтрокаТЗ.Сумма * СтрокаТЗ.ПроцентКВ / 100, 2); 
		
	КонецЦикла;	
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьРеквизитыОперации(ВидОперации)
	
	Возврат ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ВидОперации, "ФиксированнаяСебестоимость, СводныйУчет, УчетПоДоговорам, УчетПоНоменклатуре, ПривязыватьКРеализации");
	
КонецФункции	

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьВидимость(ЭтаФорма)
	
	Объект = ЭтаФорма.Объект;

	РеквизитыОперации = ПолучитьРеквизитыОперации(Объект.ВидОперации);
	
	ЭтаФорма.Элементы.ПродажиДокумент.Видимость    = НЕ РеквизитыОперации.СводныйУчет;
	ЭтаФорма.Элементы.ПродажиДокументVIN.Видимость = НЕ РеквизитыОперации.СводныйУчет;
	ЭтаФорма.Элементы.ПродажиСуммаПлан.Видимость   = НЕ РеквизитыОперации.СводныйУчет;
	ЭтаФорма.Элементы.ПродажиСумма.Видимость       = НЕ РеквизитыОперации.СводныйУчет;
	
	ЭтаФорма.Элементы.ПродажиПроцентКВПлан.Видимость = НЕ РеквизитыОперации.ФиксированнаяСебестоимость И НЕ РеквизитыОперации.СводныйУчет;
	ЭтаФорма.Элементы.ПродажиПроцентКВ.Видимость     = НЕ РеквизитыОперации.ФиксированнаяСебестоимость И НЕ РеквизитыОперации.СводныйУчет;
	ЭтаФорма.Элементы.ГруппаПроцентКВ.Видимость      = НЕ РеквизитыОперации.ФиксированнаяСебестоимость И НЕ РеквизитыОперации.СводныйУчет;
	
	ЭтаФорма.Элементы.ПродажиГруппаРеализация.Видимость = РеквизитыОперации.ПривязыватьКРеализации;
	
КонецПроцедуры	


&НаКлиенте
Процедура ВидОперацииПриИзменении(Элемент)
	
	ВидОперацииПриИзмененииСервер();
	
КонецПроцедуры

&НаСервере
Процедура ВидОперацииПриИзмененииСервер()
	
	УстановитьВидимость(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьФактПоПлану(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗаполнитьФактПоПлануЗавершение", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, "Установить фактические суммы равные плановым?", РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Да);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьФактПоПлануЗавершение(Ответ, ДопПараметры) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;	
	
	Для каждого СтрокаТЗ из Объект.Продажи Цикл
		
		СтрокаТЗ.СуммаКВ   = СтрокаТЗ.СуммаКВПлан;
		СтрокаТЗ.ПроцентКВ = СтрокаТЗ.ПроцентКВПлан;
		СтрокаТЗ.Сумма     = СтрокаТЗ.СуммаПлан;
		
	КонецЦикла;	
	
КонецПроцедуры


