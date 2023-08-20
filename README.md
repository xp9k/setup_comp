# setup_comp
Скрипт автоматизации настройки М ОС

Скрипт для настройки рабочего места. Имеет графический и консольный интерфейс. Переключение между осуществляется настройкой в скрипте параметром use_gui=true / false.
Также, если раскомментировать параметры с паролями, то  будут использованы указанные, в противном случае будут запросы паролей при настройке.<br/>
Для настройки ключей ssh и veyon (+ файл конфига) необходимые файлы должны лежать в папке с скриптом.
Для выполнения сразу нескольких команд:<br/>
-в консольном режиме через пробел указать номера пунктов настроек<br/>
-в графическом просто отметить мышкой необходимые пункты<br/>
Можно скопировать руту в ~/ и использовать как траблшутинг

Список меню:
	"Обновить систему"
  "Переименовать компьютер (требуется перезагрузка)"
  "Создать пользователей по умолчанию"
  "Пересоздать учетную запись Ученика"
  "Заблокировать Рабочий стол Ученика"
  "Разблокировать Рабочий стол Ученика"
  "Установить автологин"
  "Установить открытый ssh ключ для root"
  "Установить и настроить Veyon"
  "Убрать меню GRUB"
  "Убрать 30-секундное ожидание у учетной записи Ученика"
  "Chrome по умолчанию у Ученика"
  "Удалить учетку User"
  "Переустановить KDE Plasma"
  "Включить WoL"
  "Включить авторизацию через mos.ru"
  "Отключить авторизацию через mos.ru"
  "Включить гостевой вход"
  "Отключить гостевой вход"
  "Перезагрузить"

Пример:<br/>
![Графический режим](https://github.com/xp9k/setup_comp/blob/main/Screenshot_1.png)
![Консольный режим](https://github.com/xp9k/setup_comp/blob/main/Screenshot_2.png)
