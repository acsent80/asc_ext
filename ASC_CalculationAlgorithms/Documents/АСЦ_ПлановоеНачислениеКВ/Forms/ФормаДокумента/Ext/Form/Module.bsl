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
	УстановитьВидимость();
	УстановитьОграниченияЭлементов();
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	// СтандартныеПодсистемы.ДатыЗапретаИзменения
	ДатыЗапретаИзменения.ОбъектПриЧтенииНаСервере(ЭтаФорма, ТекущийОбъект);
	// Конец СтандартныеПодсистемы.ДатыЗапретаИзменения
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	Себестоимость = Объект.Сумма - Объект.СуммаКВ;
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	УстановитьСостояниеДокумента();
	Себестоимость = Объект.Сумма - Объект.СуммаКВ;
	
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
Процедура СуммаПриИзменении(Элемент)
	
	Реквизиты = ПолучитьРеквизитыОперации(Объект.ВидОперации);
	Если Реквизиты.ФиксированнаяСебестоимость Тогда
		Объект.СуммаКВ = Объект.Сумма - Себестоимость;
	ИначеЕсли Элементы.ПроцентКВ.Видимость Тогда	
		Объект.СуммаКВ = Объект.Сумма * Объект.ПроцентКВ / 100;
		Себестоимость = Объект.Сумма - Объект.СуммаКВ;
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура ПроцентКВПриИзменении(Элемент)
	
	Объект.СуммаКВ = Объект.Сумма * Объект.ПроцентКВ / 100;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьРеквизитыОперации(ВидОперации)
	
	Возврат ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ВидОперации, 
		"ФиксированнаяСебестоимость");
	
КонецФункции	

&НаСервере
Процедура УстановитьВидимость()
	
	ЭтаФорма.Элементы.ВидОперации.ТолькоПросмотр = ЗначениеЗаполнено(Объект.Основание);	
	ЭтаФорма.Элементы.Реализация.ТолькоПросмотр  = ЗначениеЗаполнено(Объект.Основание);	
	ЭтаФорма.Элементы.Основание.Видимость        = ЗначениеЗаполнено(Объект.Основание);	
	
	ЭтаФорма.Элементы.ОтчетПосредника.Видимость  = ЗначениеЗаполнено(Объект.ОтчетПосредника);	
	
	НастройкиПолей = Документы.АСЦ_ПлановоеНачислениеКВ.ПолучитьНастройкиПолей(Объект.ВидОперации);
	Для каждого СтрокаТЧ из НастройкиПолей Цикл
		
		Реквизит = СтрокаТЧ.Реквизит;
		Если НЕ ЗначениеЗаполнено(Реквизит) Тогда
			Реквизит = СтрокаТЧ.Имя;
		КонецЕсли;	
		
		Попытка
			ЭтаФорма.Элементы[Реквизит].Видимость = СтрокаТЧ.Видимость;
			ЭтаФорма.Элементы[СтрокаТЧ.Имя].Заголовок = СтрокаТЧ.Заголовок;
		Исключение
		КонецПопытки;	
		
	КонецЦикла;
	
КонецПроцедуры	

&НаСервереБезКонтекста
Функция ПолучитьОграниченияВидаОперации(ВидОперации)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Ссылка", ВидОперации);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Спр.Статья КАК Статья
	|ИЗ
	|	Справочник.АСЦ_ВидыОперацийПлановоеНачислениеКВ.ДоступныеСтатьи КАК Спр
	|ГДЕ
	|	Спр.Ссылка = &Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Спр.ЦФО КАК ЦФО
	|ИЗ
	|	Справочник.АСЦ_ВидыОперацийПлановоеНачислениеКВ.ДоступныеЦФО КАК Спр
	|ГДЕ
	|	Спр.Ссылка = &Ссылка";
	
	МассивРезультатов = Запрос.ВыполнитьПакет();
	
	СтруктураРезультата = Новый Структура;
	СтруктураРезультата.Вставить("ДоступныеСтатьи", МассивРезультатов[0].Выгрузить().ВыгрузитьКолонку("Статья"));
	СтруктураРезультата.Вставить("ДоступныеЦФО",    МассивРезультатов[1].Выгрузить().ВыгрузитьКолонку("ЦФО"));
	
	Возврат СтруктураРезультата;
	
КонецФункции	

&НаСервере
Процедура УстановитьОграниченияЭлементов()
	
	СтруктураОграничений =  ПолучитьОграниченияВидаОперации(Объект.ВидОперации);
	Этаформа.Элементы.Статья.СписокВыбора.ЗагрузитьЗначения(СтруктураОграничений.ДоступныеСтатьи);
	Этаформа.Элементы.Статья.РежимВыбораИзСписка = (Этаформа.Элементы.Статья.СписокВыбора.Количество() > 0);
	
	Этаформа.Элементы.ЦФО.СписокВыбора.ЗагрузитьЗначения(СтруктураОграничений.ДоступныеЦФО);
	Этаформа.Элементы.ЦФО.РежимВыбораИзСписка = (Этаформа.Элементы.ЦФО.СписокВыбора.Количество() > 0);
	
КонецПроцедуры	

&НаКлиенте
Процедура ВидОперацииПриИзменении(Элемент)
	
	УстановитьВидимость();
	УстановитьОграниченияЭлементов();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьОрганизацию(Команда)
	ЗаполнитьОрганизациюНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОрганизациюНаСервере()
	
	СтруктураКВ = РегистрыСведений.АСЦ_ПлановыеПроцентыКВ.ПолучитьСтруктуруПроцентаКВ(Объект.Комитент, Объект.ДЦ, Объект.Дата);
	Объект.Организация = СтруктураКВ.Организация;
	Объект.ПроцентКВ   = СтруктураКВ.ПроцентКВ;
	Объект.СуммаКВ     = Окр(Объект.Сумма * Объект.ПроцентКВ / 100, 2);
	
КонецПроцедуры

&НаСервере
Процедура НоменклатураПриИзмененииНаСервере()
	
	Если Объект.ВидОперации.ФиксированнаяСебестоимость Тогда
		
		ТаблицаЦен = Ценообразование.ПолучитьТаблицуЦенНоменклатуры(Объект.Номенклатура, Константы.ТипЦенПлановойСебестоимостиНоменклатуры.Получить(), Объект.Дата);
		Себестоимость = 0;
		Если ТаблицаЦен.Количество() > 0 Тогда
			Себестоимость = ТаблицаЦен[0].Цена;
		КонецЕсли;	
		Объект.СуммаКВ = Объект.Сумма - Себестоимость;
		
	КонецЕсли;	
	
	База = Справочники.ВнешниеИнформационныеБазы.НайтиПоНаименованию("Юникус");
	НастройкаСтатьиДоходов = Справочники.СоответствиеВнешнимИБ.НайтиПоНаименованию("Номенклатура <-> Статьи доходов",,, База.ТипБД);
	Объект.Статья = АСЦ_ПоискОбъектов.ПолучитьОбъектПоСоотвествию(Строка(Объект.Номенклатура), НастройкаСтатьиДоходов, База);
	
КонецПроцедуры

&НаКлиенте
Процедура НоменклатураПриИзменении(Элемент)
	НоменклатураПриИзмененииНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура СебестоимостьПриИзменении(Элемент)
	
	Объект.СуммаКВ = Объект.Сумма - Себестоимость;
	
КонецПроцедуры

&НаСервере
Процедура ЦФОПриИзмененииНаСервере()
	
	Статья = Справочники.АСЦ_ВидыОперацийПлановоеНачислениеКВ.ПолучитьСтатьюПоЦФО(Объект.ВидОперации, Объект.ЦФО);
	Если ЗначениеЗаполнено(Статья) Тогда
		Объект.Статья = Статья;
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура ЦФОПриИзменении(Элемент)
	ЦФОПриИзмененииНаСервере();
КонецПроцедуры
