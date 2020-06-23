import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

/* Function: createSocket
 * ______________________
 *   - joins channel of specific topic_id and renders topic's comments onsuccess
 *   - adds event listener to add comment button which pushes new comment to channel 
 *     (goes to handle_in)
 *   - turns on channel to listen for new comments
 */   
const createSocket = (topic_id) => {
  let channel = socket.channel(`comments:${topic_id}`, {})
  channel.join()
    .receive("ok", resp => { 
      renderComments(resp.comments);
    })
    .receive("error", resp => { 
      console.log("Unable to join", resp) 
    })

  document.querySelector('button').addEventListener('click', () => {
    const content = document.querySelector('textarea').value;
    channel.push("comment:add", { content: content });
  });

  channel.on(`comments:${topic_id}:new`, renderNewComment);
}

/* Function: renderComments
 * ________________________
 *   - generates html for each comment and puts it all in collection div
 */   
function renderComments(comments) {
  const renderedComments = comments.map(comment => {
    return commentTemplate(comment);
  });

  document.querySelector('.collection').innerHTML = renderedComments.join('');
}

/* Function: renderNewComment
 * __________________________
 *   - generates html for new comment and adds it to collection div
 */   
function renderNewComment(event) {
  const renderedComment = commentTemplate(event.comment);
  document.querySelector('.collection').innerHTML += renderedComment;
}

/* Function: commentTemplate
 * _________________________
 *   - sets default email to Anonymous and sets email if user who made comment had account
 *   - returns html list item for each comment
 */   
const commentTemplate = (comment) => {
  let email = 'Anonymous';

  if(comment.user) {
    email = comment.user.email;
  }

  return `
      <li class="collection-item">
        ${comment.content}
        <div class="secondary-content">
          ${email}
        </div>
      </li>
    `;
}

window.createSocket = createSocket;