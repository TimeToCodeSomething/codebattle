import { useCallback, useState, useMemo } from 'react';

import { useContextMenu } from 'react-contexify';

/**
 * @typedef {{ user: {name: string, isBot: boolean, userId: number, canInvite: boolean}}} MenuRequest
 *
 * @return {{menuId: number, menuRequest: MenuRequest, displayMenu: Function}}
 *
 */
const useChatContextMenu = ({
  type,
  users,
  canInvite = false,
}) => {
  const menuConf = useMemo(() => ({ id: `${type}-chat` }), [type]);
  const { show } = useContextMenu(menuConf);

  const [menuRequest, setMenuRequest] = useState();

  const displayMenu = useCallback(event => {
    const { userId, userName } = event.currentTarget.dataset;

    if (!userId) {
      return;
    }

    const user = users.find(({ id }) => id === Number(userId));
    const request = {
      user: {
        name: user?.name || userName,
        isBot: user?.isBot,
        userId: user?.id || Number(userId),
        canInvite: user ? canInvite : false,
      },
    };

    setMenuRequest(request);
    show({ event });
  }, [show, users, canInvite, setMenuRequest]);

  return {
    menuId: menuConf.id,
    menuRequest,
    displayMenu,
  };
};

export default useChatContextMenu;
